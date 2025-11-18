// lib/features/profile/edit_profile_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/user_model.dart';
import 'package:absen/data/models/profile_model.dart';
import 'package:absen/features/profile/data/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  ProfileModel? _user;
  File? _pickedFile;
  String? _pickedBase64; // data:image/...base64, ready to send
  bool _isLoading = false;

  final _repo = ProfileRepository(); // implement updateProfile in repository

  @override
  void initState() {
    super.initState();
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    final u = await _repo.getProfile();
    if (!mounted) return;
    setState(() {
      _user = u;
      _nameController.text = u.data?.name ?? '';
    });
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: src,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await File(file.path).readAsBytes();
      final b64 = base64Encode(bytes);
      setState(() {
        _pickedFile = File(file.path);
        _pickedBase64 = 'data:image/png;base64,$b64';
      });
    } catch (e) {
      debugPrint('pick image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal memilih gambar')));
      }
    }
  }

  Future<void> _showPickOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.of(c).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil foto'),
              onTap: () {
                Navigator.of(c).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Batal'),
              onTap: () => Navigator.of(c).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // priority: picked image -> cached user profilePhotoUrl -> initials placeholder
    if (_pickedFile != null) {
      return CircleAvatar(
        radius: 44,
        backgroundColor: Colors.grey[200],
        backgroundImage: FileImage(_pickedFile!),
      );
    }

    final url = _user?.data?.profilePhotoUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 44,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(url),
      );
    }

    final initials = (_user?.data?.name ?? 'U')
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .take(2)
        .join();
    return CircleAvatar(
      radius: 44,
      backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.15),
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    final photoBase64 = _pickedBase64; // may be null

    setState(() => _isLoading = true);

    try {
      // repo.updateProfile should return ProfileModel or updated user object
      final resp = await _repo.updateProfile(
        name: newName,
        profilePhotoBase64: photoBase64,
      );
      // assume resp.data contains user info (ProfileModel shape depends on your API)
      // update local prefs
      final updatedUser = UserModel.fromJson(
        resp.toJson()['data'] ?? resp.toJson(),
      );
      await PrefsService.saveUserJson(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      // pop back and optionally return true
      context.router.pop(true);
      // if (resp != null) {
      //   // convert ProfileModel -> UserModel if necessary; here we try to extract user fields
      // } else {
      //   throw Exception('Response null');
      // }
    } catch (e) {
      debugPrint('update profile error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update profil: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF4A60F0),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // avatar + change button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _showPickOptions,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF0EA5E9),
                    ),
                    label: const Text(
                      'Ubah Foto',
                      style: TextStyle(color: Color(0xFF0EA5E9)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama lengkap',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF4A60F0),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama wajib diisi'
                        : null,
                  ),

                  const SizedBox(height: 12),

                  // email (readonly)
                ],
              ),
            ),

            const SizedBox(height: 24),

            // actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => context.router.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A60F0),
                      side: const BorderSide(color: Color(0xFF4A60F0)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
