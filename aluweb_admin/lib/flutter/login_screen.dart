import 'package:aluweb_admin/flutter/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  final String slug;
  const LoginScreen({super.key, required this.slug});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AdminScreen(slug: widget.slug), // 👈 بعد اللوجين
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'بيانات غلط، حاول تاني';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText, // 👈 مش true ثابتة
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    // 👈 ضيف ده
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('دخول'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
