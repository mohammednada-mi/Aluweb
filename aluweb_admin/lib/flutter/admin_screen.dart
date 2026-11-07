import 'package:aluweb_admin/flutter/categories_page.dart';
import 'package:aluweb_admin/flutter/images_page.dart';

import 'package:aluweb_admin/flutter/settings_page.dart';
import 'package:flutter/material.dart';


class AdminScreen extends StatefulWidget {
  final String slug;
  const AdminScreen({super.key, required this.slug});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<String> _menuItems = ['الإعدادات', 'الأقسام', 'الصور'];

  final List<IconData> _menuIcons = [
    Icons.settings,
    Icons.category,
    Icons.image,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 42, 61),
        title: const Text('الأدمن بانل', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        // 👈 بدل القايمة الجانبية الثابتة
        child: Container(
          color: const Color.fromARGB(255, 5, 42, 61),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'الأدمن بانل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ...List.generate(_menuItems.length, (index) {
                return ListTile(
                  selected: _selectedIndex == index,
                  selectedTileColor: Colors.white24,
                  leading: Icon(_menuIcons[index], color: Colors.white),
                  title: Text(
                    _menuItems[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => setState(() => _selectedIndex = index),
                );
              }),
              const Spacer(),
             
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? SettingsPage(slug: widget.slug)
          : _selectedIndex == 1
          ? CategoriesPage(slug: widget.slug)
          : ImagesPage(slug: widget.slug),
    );
  }
}
