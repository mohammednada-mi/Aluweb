import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImagesPage extends StatefulWidget {
  final String slug;
  const ImagesPage({super.key, required this.slug});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  List<Map<String, dynamic>> images = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // جيب الأقسام
    final catsResponse = await Supabase.instance.client
        .from('products')
        .select()
        .eq('workshop_id', widget.slug);

    // جيب الصور
    final imgsResponse = await Supabase.instance.client
        .from('images')
        .select()
        .eq('workshop_id', widget.slug);

    setState(() {
      categories = List<Map<String, dynamic>>.from(catsResponse);
      images = List<Map<String, dynamic>>.from(imgsResponse);
      isLoading = false;
    });
  }

  Future<void> _deleteImage(int id) async {
    await Supabase.instance.client
        .from('images')
        .delete()
        .eq('id', id);
    _loadData();
  }

  Future<void> _addImage() async {
    final titleController = TextEditingController();
    XFile? pickedImage;
    String? selectedCat;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة صورة', textDirection: TextDirection.rtl),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // اختيار القسم
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'اختر القسم',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['name'],
                        child: Text(cat['name']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedCat = value),
                  ),
                ),
                const SizedBox(height: 16),
                // عنوان الصورة
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الصورة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // اختيار الصورة
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 70,
                    );
                    if (image != null) {
                      setDialogState(() => pickedImage = image);
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: pickedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 40, color: Colors.grey),
                              Text('اختر صورة',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : Image.network(pickedImage!.path, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 5, 42, 61),
              ),
              onPressed: () async {
                if (selectedCat == null ||
                    pickedImage == null) return;

                final imageBytes = await pickedImage!.readAsBytes();
                final fileName =
                    '${widget.slug}/${DateTime.now().millisecondsSinceEpoch}.jpg';

                await Supabase.instance.client.storage
                    .from('images')
                    .uploadBinary(fileName, imageBytes);

                final imageUrl = Supabase.instance.client.storage
                    .from('images')
                    .getPublicUrl(fileName);

                await Supabase.instance.client.from('images').insert({
                  'category_name': selectedCat,
                  'title': titleController.text.trim(),
                  'imageUrl': imageUrl,
                  'workshop_id': widget.slug,
                });

                if (mounted) Navigator.pop(context);
                _loadData();
              },
              child: const Text('إضافة',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الصور',
              style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: images.length + 1,
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 40, color: Colors.grey),
                          Text('إضافة صورة',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                final image = images[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            image['imageUrl'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                image['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('حذف الصورة'),
                                  content: const Text('هتحذف الصورة دي؟'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('إلغاء'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteImage(image['id']);
                                      },
                                      child: const Text('حذف',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}