import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';


class CategoriesPage extends StatefulWidget {
  final String slug;
  const CategoriesPage({super.key, required this.slug});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await Supabase.instance.client
        .from('products')
        .select()
        .eq('workshop_id', widget.slug);

    setState(() {
      categories = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> _deleteCategory(int id) async {
    await Supabase.instance.client.from('products').delete().eq('id', id);

    _loadCategories();
  }

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    XFile? pickedImage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة قسم جديد', textDirection: TextDirection.rtl),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم القسم',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800, // 👈 بيصغر الصورة قبل الرفع
                    maxHeight: 800,
                    imageQuality: 70, // 👈 بيضغطها
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
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: Colors.grey,
                            ),
                            Text(
                              'اختر صورة',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : Image.network(pickedImage!.path, fit: BoxFit.cover),
                ),
              ),
            ],
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
               
                if (nameController.text.isEmpty || pickedImage == null) {
                 
                  return;
                }

                // قراءة الصورة كـ bytes مباشرة 👈 ده الحل للويب
                
                final imageBytes = await pickedImage!.readAsBytes();
              
                final fileName =
                    '${widget.slug}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                 
await Supabase.instance.client.storage
                    .from('images')
                    .uploadBinary(fileName, imageBytes);
                    
                

                final imageUrl = Supabase.instance.client.storage
                    .from('images')
                    .getPublicUrl(fileName);

                await Supabase.instance.client.from('products').insert({
                  'name': nameController.text.trim(),
                  'imageUrl': imageUrl,
                  'workshop_id': widget.slug,
                });

                if (mounted) Navigator.pop(context);
                _loadCategories();
              },
              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
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
          const Text(
            'الأقسام',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length + 1, // 👈 +1 عشان زر الإضافة
              itemBuilder: (context, index) {
                // آخر card هو زر الإضافة
                if (index == categories.length) {
                  return GestureDetector(
                    onTap: _addCategory,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 40, color: Colors.grey),
                          Text(
                            'إضافة قسم',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final category = categories[index];
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
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            category['imageUrl'],
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
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('حذف القسم'),
                                  content: Text(
                                    'هتحذف قسم "${category['name']}"؟',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('إلغاء'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteCategory(category['id']);
                                      },
                                      child: const Text(
                                        'حذف',
                                        style: TextStyle(color: Colors.white),
                                      ),
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
