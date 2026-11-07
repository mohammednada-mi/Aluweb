import 'package:aluweb/flutter/screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  final String slug;
  const MainScreen({super.key, required this.slug});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  //! المنتجات التي تحتوي على الصور والعنوان

  List<Map<String, dynamic>> products = [];
  Map<String, dynamic> settings = {};

  // 2. في initState
  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadSettings();
  }

  Future<void> _loadProducts() async {
    final response = await Supabase.instance.client
        .from('products')
        .select()
        .eq('workshop_id', widget.slug); // 👈 ضيف ده

    setState(() {
      products = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _loadSettings() async {
    final response = await Supabase.instance.client
        .from('settings')
        .select()
        .eq('workshop_id', widget.slug) // 👈 ضيف ده
        .single();

    setState(() {
      settings = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    settings['workshop_name'] ?? 'جاري التحميل',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),

                  InkWell(
                    onTap: () {
                      _makePhoneCall(settings['phone'] ?? '');
                    },
                    child: const Text(
                      'اتصل بنا',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  const Icon(Icons.phone_enabled, color: Colors.blue, size: 30),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. الخلفية - مش هتحدد height هنا خالص
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 5, 42, 61),
                      ),
                    ),
                  ),

                  // 2. Row رئيسي بيحتوي على العنصرين مع بعض
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // العنصر الأيسر
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              _launchURL(settings['maps_url'] ?? '');
                            },
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "عنواننا على الخريطة",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SvgPicture.asset(
                                    'assets/icons/google-map-icon.svg',
                                    width: 24,
                                    height: 24,
                                    allowDrawingOutsideViewBox: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // العنصر الأيمن
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  settings['address'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.blueGrey,
                                ),
                                child: const Icon(
                                  Icons.home,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //Todo :links
              Row(
                children: [
                  const SizedBox(width: 20),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(
                        7,
                      ), // حواف دائرية ناعمة زي باقي الأزرار
                    ),
                    child: InkWell(
                      onTap: () {
                        _launchURL(settings['tiktok_url'] ?? '');
                      },
                      child: const Icon(
                        Icons.tiktok,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 17, 255),
                      borderRadius: BorderRadius.circular(
                        7,
                      ), // حواف دائرية ناعمة زي باقي الأزرار
                    ),
                    child: InkWell(
                      onTap: () {
                        _launchURL(settings['facebook_url'] ?? '');
                      },
                      child: const Icon(
                        Icons.facebook,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 183, 6),
                      borderRadius: BorderRadius.circular(
                        7,
                      ), // حواف دائرية ناعمة زي باقي الأزرار
                    ),
                    // عشان يحتفظ بلون الأخضر بتاع الكونتينر
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        _launchURL(
                          'https://wa.me/+20${settings['whatsapp_url'] ?? ''}',
                        );
                      },
                      child: const Center(
                        // 👈 هي دي اللي بتسفتر الأيقونة بالطول والعرض بالظبط
                        child: FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                    ), // 👈 مسافة 16 بكسل من اليمين
                    child: Text(
                      'أعمالنا',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              //!الاقسام
              Container(height: 5, color: Colors.black),
              GridView.builder(
                shrinkWrap: true, // 👈 عشان جوا Column
                physics: const NeverScrollableScrollPhysics(), // 👈 السكرول للـ SingleChildScrollView بره
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 👈 اتنين في كل صف
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                      (MediaQuery.of(context).size.width / 2) /
                      (MediaQuery.of(context).size.height * 0.69),
                  // 👈 نسبة العرض للطول، غيرها حسب ذوقك
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryScreen(
                            
                              categoryName: products[index]['name'],
                              workshopId: widget.slug, // 👈 اسم القسم
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  products[index]['imageUrl']!,
                                  width: double.infinity,

                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              products[index]['name']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
