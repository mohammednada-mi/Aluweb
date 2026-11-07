import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName; // 👈 اسم القسم
  final String workshopId;
  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.workshopId,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final response = await Supabase.instance.client
        .from('images')
        .select()
        .eq('category_name', widget.categoryName)
        .eq('workshop_id', widget.workshopId); // 👈 بيجيب صور القسم ده بس

    setState(() {
      images = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.black,
                        insetPadding: EdgeInsets.zero,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pop(context), // 👈 دوس تاني يقفل
                          child: InteractiveViewer(
                            child: Image.network(
                              images[index]['imageUrl'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[index]['imageUrl'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        images[index]['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
