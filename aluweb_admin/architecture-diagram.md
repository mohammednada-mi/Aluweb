# AluWeb Admin — System Architecture

## System Overview

**AluWeb Admin** is a multi-tenant Flutter Web admin panel for managing workshop portfolios (aluminum workshops / ورش ألمونيوم). Each workshop is identified by a URL **slug** and has its own settings, product categories, and image gallery — all backed by **Supabase** (Auth, Database, Storage).

---

## Architecture Diagram

```mermaid
graph TB
    subgraph CLIENT["Flutter Web App"]
        direction TB
        MAIN["main.dart<br/>──────────<br/>• Supabase.initialize()<br/>• Extracts slug from URL<br/>• Launches MyApp"]

        subgraph NAV["Navigation Flow"]
            direction LR
            LOGIN["LoginScreen<br/>──────────<br/>• Email / Password form<br/>• signInWithPassword()"]
            ADMIN["AdminScreen<br/>──────────<br/>• AppBar + Drawer<br/>• 3-tab navigation index"]
        end

        subgraph PAGES["Admin Pages"]
            direction LR
            SETTINGS["SettingsPage<br/>──────────<br/>• workshop_name<br/>• address / phone<br/>• maps, facebook,<br/> whatsapp, tiktok URLs<br/>• Load & Save"]
            CATEGORIES["CategoriesPage<br/>──────────<br/>• GridView of categories<br/>• Add category dialog<br/> (name + image)<br/>• Delete category"]
            IMAGES["ImagesPage<br/>──────────<br/>• GridView of images<br/>• Add image dialog<br/> (category, title, image)<br/>• Delete image<br/>• Filter by category"]
        end
    end

    subgraph SUPABASE["Supabase Backend"]
        direction TB
        AUTH["Supabase Auth<br/>──────────<br/>Email + Password"]

        subgraph DB["PostgreSQL Database"]
            direction LR
            T_SETTINGS["settings table<br/>──────────<br/>workshop_id (slug)<br/>workshop_name<br/>address, phone<br/>maps_url<br/>facebook_url<br/>whatsapp_url<br/>tiktok_url"]
            T_PRODUCTS["products table<br/>──────────<br/>id<br/>name<br/>imageUrl<br/>workshop_id (slug)"]
            T_IMAGES["images table<br/>──────────<br/>id<br/>category_name<br/>title<br/>imageUrl<br/>workshop_id (slug)"]
        end

        STORAGE["Supabase Storage<br/>──────────<br/>Bucket: 'images'<br/>Path: {slug}/{timestamp}.jpg"]
    end

    subgraph DEPS["Key Dependencies"]
        direction LR
        D1["supabase_flutter"]
        D2["image_picker"]
        D3["cached_network_image"]
        D4["flutter_image_compress"]
    end

    %% ── Flow connections ──
    MAIN -->|"slug"| LOGIN
    LOGIN -->|"Auth success → pushReplacement"| ADMIN
    ADMIN -->|"index 0"| SETTINGS
    ADMIN -->|"index 1"| CATEGORIES
    ADMIN -->|"index 2"| IMAGES

    %% ── Supabase connections ──
    LOGIN --->|"signInWithPassword()"| AUTH
    SETTINGS --->|"SELECT / UPDATE"| T_SETTINGS
    CATEGORIES --->|"SELECT / INSERT / DELETE"| T_PRODUCTS
    CATEGORIES --->|"uploadBinary() + getPublicUrl()"| STORAGE
    IMAGES --->|"SELECT (products)"| T_PRODUCTS
    IMAGES --->|"SELECT / INSERT / DELETE"| T_IMAGES
    IMAGES --->|"uploadBinary() + getPublicUrl()"| STORAGE

    %% ── Multi-tenancy ──
    T_SETTINGS -.->|"workshop_id = slug"| T_PRODUCTS
    T_PRODUCTS -.->|"category_name links"| T_IMAGES

    %% ── Styling ──
    classDef client fill:#e3f2fd,stroke:#1565c0,color:#0d47a1
    classDef supabase fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20
    classDef page fill:#fff3e0,stroke:#e65100,color:#bf360c
    classDef table fill:#f3e5f5,stroke:#6a1b9a,color:#4a148c
    classDef dep fill:#f5f5f5,stroke:#9e9e9e,color:#616161

    class MAIN,LOGIN,ADMIN client
    class SETTINGS,CATEGORIES,IMAGES page
    class AUTH,STORAGE supabase
    class T_SETTINGS,T_PRODUCTS,T_IMAGES table
    class D1,D2,D3,D4 dep
```

---

## Component Interaction Sequence

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter Web App
    participant Auth as Supabase Auth
    participant DB as Supabase DB
    participant Store as Supabase Storage

    Note over App: Extract slug from URL path

    User->>App: Enter email + password
    App->>Auth: signInWithPassword()
    Auth-->>App: Auth session
    App->>App: Navigate → AdminScreen

    rect rgb(255, 243, 224)
        Note over App,DB: Settings Page
        App->>DB: SELECT from settings WHERE workshop_id = slug
        DB-->>App: Workshop settings
        User->>App: Edit & save settings
        App->>DB: UPDATE settings WHERE workshop_id = slug
    end

    rect rgb(227, 242, 253)
        Note over App,Store: Categories Page
        App->>DB: SELECT from products WHERE workshop_id = slug
        DB-->>App: Categories list
        User->>App: Add new category (name + image)
        App->>Store: uploadBinary(slug/timestamp.jpg)
        Store-->>App: Public URL
        App->>DB: INSERT into products (name, imageUrl, workshop_id)
    end

    rect rgb(232, 245, 233)
        Note over App,Store: Images Page
        App->>DB: SELECT from products WHERE workshop_id = slug
        App->>DB: SELECT from images WHERE workshop_id = slug
        DB-->>App: Categories + Images
        User->>App: Add new image (category, title, image)
        App->>Store: uploadBinary(slug/timestamp.jpg)
        Store-->>App: Public URL
        App->>DB: INSERT into images (category_name, title, imageUrl, workshop_id)
    end
```

---

## Data Model (ER Diagram)

```mermaid
erDiagram
    WORKSHOP ||--|| SETTINGS : "has"
    WORKSHOP ||--o{ PRODUCTS : "has many"
    WORKSHOP ||--o{ IMAGES : "has many"
    PRODUCTS ||--o{ IMAGES : "category_name"

    WORKSHOP {
        string slug PK "URL path segment"
    }

    SETTINGS {
        string workshop_id FK "= slug"
        string workshop_name
        string address
        string phone
        string maps_url
        string facebook_url
        string whatsapp_url
        string tiktok_url
    }

    PRODUCTS {
        int id PK
        string name
        string imageUrl
        string workshop_id FK "= slug"
    }

    IMAGES {
        int id PK
        string category_name FK "= product name"
        string title
        string imageUrl
        string workshop_id FK "= slug"
    }
```

---

## Widget Tree

```mermaid
graph TD
    MA["MaterialApp<br/>(locale: ar, theme: Cairo font)"]
    MA --> LS["LoginScreen"]
    LS -->|"on success"| AS["AdminScreen"]
    AS --> DR["Drawer<br/>(3 menu items)"]
    AS --> SP["SettingsPage"]
    AS --> CP["CategoriesPage"]
    AS --> IP["ImagesPage"]

    SP --> SSV["SingleChildScrollView"]
    SSV --> TF1["7× TextField<br/>(RTL)"]
    SSV --> BTN1["ElevatedButton<br/>'حفظ'"]

    CP --> GV1["GridView.builder<br/>(3 columns)"]
    GV1 --> CC["Category Cards<br/>(Image + Name + Delete)"]
    GV1 --> AC["Add Category Card<br/>(+ icon)"]
    AC --> DLG1["AlertDialog<br/>(TextField + ImagePicker)"]

    IP --> GV2["GridView.builder<br/>(3 columns)"]
    GV2 --> IC["Image Cards<br/>(Image + Title + Delete)"]
    GV2 --> AI["Add Image Card<br/>(+ icon)"]
    AI --> DLG2["AlertDialog<br/>(Dropdown + TextField + ImagePicker)"]

    classDef screen fill:#bbdefb,stroke:#1565c0
    classDef widget fill:#fff9c4,stroke:#f9a825
    classDef dialog fill:#ffccbc,stroke:#d84315

    class LS,AS,SP,CP,IP screen
    class SSV,GV1,GV2,TF1,BTN1,CC,AC,IC,AI,DR widget
    class DLG1,DLG2 dialog
```

> [!NOTE]
> The project uses a **soft foreign key** pattern: `images.category_name` references `products.name` by value rather than by `products.id`. The `workshop_id` (slug) acts as the multi-tenancy discriminator across all three tables.
