import 'package:flutter/material.dart';

class ProfileUploadWidget extends StatelessWidget {
  final VoidCallback onTap;

  const ProfileUploadWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade50,
            ),
            child: const Icon(Icons.camera_alt, size: 40, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Upload foto profil"),
      ],
    );
  }
}
