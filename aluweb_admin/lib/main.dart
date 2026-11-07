import 'package:aluweb_admin/flutter/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: '******************', anonKey: '**********');

  // بياخد الـ slug من الـ URL
  final slug = Uri.base.pathSegments.isNotEmpty
      ? Uri.base.pathSegments.first
      : 'amal';

  runApp(MyApp(slug: slug));
}

class MyApp extends StatelessWidget {
  final String slug;
  const MyApp({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'aluweb_admin',
        fontFamilyFallback: const ['sans-serif', 'Arial'],
      ),
      locale: const Locale('ar'),
      home: LoginScreen(slug: slug), // 👈 بيبدأ بشاشة اللوجين
    );
  }
}
