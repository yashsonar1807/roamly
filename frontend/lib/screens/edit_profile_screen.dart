import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialProfile;

  const EditProfileScreen({super.key, required this.initialProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;
  late TextEditingController _profileImageController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile['name']);
    _bioController = TextEditingController(text: widget.initialProfile['bio']);
    _countryController = TextEditingController(text: widget.initialProfile['country']);
    _phoneController = TextEditingController(text: widget.initialProfile['phone']);
    _profileImageController = TextEditingController(text: widget.initialProfile['profileImage']);
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      country: _countryController.text.trim(),
      phone: _phoneController.text.trim(),
      profileImage: _profileImageController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          _isLoading
              ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: CircularProgressIndicator()))
              : TextButton(
                  onPressed: _saveChanges,
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Name',
                    prefixIcon: Icons.person_rounded,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _bioController,
                    label: 'Bio',
                    prefixIcon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _countryController,
                    label: 'Country',
                    prefixIcon: Icons.public_rounded,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _profileImageController,
                    label: 'Profile Image URL',
                    prefixIcon: Icons.image_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveChanges,
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
