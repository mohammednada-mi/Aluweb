import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  final String slug;
  const SettingsPage({super.key, required this.slug});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _workshopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mapsController = TextEditingController();
  final _facebookController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _tiktokController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final response = await Supabase.instance.client
        .from('settings')
        .select()
        .eq('workshop_id', widget.slug)
        .single();

    setState(() {
      _workshopNameController.text = response['workshop_name'] ?? '';
      _addressController.text = response['address'] ?? '';
      _phoneController.text = response['phone'] ?? '';
      _mapsController.text = response['maps_url'] ?? '';
      _facebookController.text = response['facebook_url'] ?? '';
      _whatsappController.text = response['whatsapp_url'] ?? '';
      _tiktokController.text = response['tiktok_url'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    await Supabase.instance.client
        .from('settings')
        .update({
          'workshop_name': _workshopNameController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'maps_url': _mapsController.text.trim(),
          'facebook_url': _facebookController.text.trim(),
          'whatsapp_url': _whatsappController.text.trim(),
          'tiktok_url': _tiktokController.text.trim(),
        })
        .eq('workshop_id', widget.slug);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحفظ بنجاح ✅'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإعدادات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildTextField('اسم الورشة', _workshopNameController),
          _buildTextField('العنوان', _addressController),
          _buildTextField('التليفون', _phoneController),
          _buildTextField('رابط الخريطة', _mapsController),
          _buildTextField('رابط فيسبوك', _facebookController),
          _buildTextField('رقم واتساب', _whatsappController),
          _buildTextField('رابط تيك توك', _tiktokController),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 5, 42, 61),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'حفظ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
