import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/profile/screens/profile_screen.dart';

class ProfileButton extends StatefulWidget {
  const ProfileButton({super.key});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  final ApiService _api = ApiService();
  String? _storedPhotoBase64;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final res = await _api.get('/auth/me');
      if (mounted) {
        final username = res['data']['username'] ?? '';
        if (username.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final photo = prefs.getString('profile_photo_$username');
          if (mounted) {
            setState(() {
              _storedPhotoBase64 = photo;
            });
          }
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _storedPhotoBase64 != null
          ? CircleAvatar(
              radius: 12,
              backgroundImage: MemoryImage(base64Decode(_storedPhotoBase64!)),
            )
          : Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      tooltip: 'Profil Saya',
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
    );
  }
}
