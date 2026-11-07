import 'package:aluweb/flutter/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: '**************', anonKey: '**************');

  final slug = Uri.base.pathSegments.isNotEmpty
      ? Uri.base.pathSegments.first
      : 'amal';

  // 👈 بيتحقق من الاشتراك
  final workshop = await Supabase.instance.client
      .from('workshops')
      .select()
      .eq('slug', slug)
      .maybeSingle();

  final isActive = workshop?['is_active'] ?? false;

  runApp(Aluweb(slug: slug, isActive: isActive));
}

class Aluweb extends StatelessWidget {
  final String slug;
  final bool isActive;
  const Aluweb({super.key, required this.slug, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'aluweb',
        fontFamilyFallback: const ['sans-serif', 'Arial'],
      ),
      home: isActive
          ? MainScreen(slug: slug) // 👈 لو مشترك
          : const InactiveScreen(), // 👈 لو مش مشترك
    );
  }
}

// 👈 شاشة انتهاء الاشتراك
class InactiveScreen extends StatelessWidget {
  const InactiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'الموقع مغلق حالياً لأعمال التحديث والتجديد. سنعود إليكم قريباً',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
