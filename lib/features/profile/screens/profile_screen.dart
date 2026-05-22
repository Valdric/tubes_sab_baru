import 'dart:convert';
import 'package:gosir/main.dart';
import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gosir/shared/widgets/animated_entry.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;
  String? _storedPhotoBase64;
  
  // Update state indicators
  bool _isUpdatingInfo = false;
  bool _isUpdatingPassword = false;

  // Form Keys
  final _infoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Password obscure states
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredPhoto(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photo = prefs.getString('profile_photo_$username');
      if (mounted) {
        setState(() {
          _storedPhotoBase64 = photo;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final username = _profile['username'] ?? '';
        
        if (username.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_photo_$username', base64String);
          if (mounted) {
            setState(() {
              _storedPhotoBase64 = base64String;
            });
            _showSuccessSnackBar('Foto profil berhasil diubah.');
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih foto: $e');
    }
  }

  Future<void> _deletePhoto() async {
    try {
      final username = _profile['username'] ?? '';
      if (username.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_photo_$username');
        if (mounted) {
          setState(() {
            _storedPhotoBase64 = null;
          });
          _showSuccessSnackBar('Foto profil berhasil dihapus.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus foto: $e');
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_storedPhotoBase64 != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deletePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/profile');
      if (mounted) {
        setState(() {
          _profile = res['data'] ?? {};
          _nameController.text = _profile['name'] ?? '';
          _usernameController.text = _profile['username'] ?? '';
          _isLoading = false;
        });
        _loadStoredPhoto(_profile['username'] ?? '');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  Future<void> _updateProfileInfo() async {
    if (!_infoFormKey.currentState!.validate()) return;

    setState(() => _isUpdatingInfo = true);
    try {
      // 1. Update Name if changed
      if (_nameController.text.trim() != (_profile['name'] ?? '')) {
        final nameRes = await _api.put('/profile/name', {
          'name': _nameController.text.trim(),
        });
        _profile = nameRes['data'] ?? _profile;
      }

      // 2. Update Username if changed
      if (_usernameController.text.trim() != (_profile['username'] ?? '')) {
        final usernameRes = await _api.put('/profile/username', {
          'username': _usernameController.text.trim().toLowerCase(),
        });
        _profile = usernameRes['data'] ?? _profile;
      }

      if (mounted) {
        setState(() {
          _isUpdatingInfo = false;
        });
        _showSuccessSnackBar('Informasi profil berhasil diperbarui.');
        _fetchData(); // Refresh info
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdatingInfo = false);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isUpdatingPassword = true);
    try {
      await _api.put('/profile/password', {
        'password': _currentPasswordController.text,
        'new_password': _newPasswordController.text,
        'confirmation_password': _confirmPasswordController.text,
      });

      if (mounted) {
        setState(() {
          _isUpdatingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
        _showSuccessSnackBar('Password berhasil diperbarui.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: -1)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 0,
              title: Text(
                'Profil Saya',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: -1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32.0 : 16.0,
                      vertical: isDesktop ? 32.0 : 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop) ...[
                          Text(
                            'Profil Saya',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelola informasi akun, keamanan, dan preferensi tema aplikasi Anda.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 32),
                        ],
                        // Responsive Layout Selector
                        isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Layout Desktop (Bento Grid 2 Column) ---
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Avatar, basic info, and theme mode card)
        Expanded(
          flex: 4,
          child: Column(
            children: [
              AnimateEntry(
                delay: Duration.zero,
                child: _buildAvatarCard(),
              ),
              const SizedBox(height: 24),
              AnimateEntry(
                delay: const Duration(milliseconds: 100),
                child: _buildSettingsCard(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Right Column (Forms for editing info & security)
        Expanded(
          flex: 6,
          child: Column(
            children: [
              AnimateEntry(
                delay: const Duration(milliseconds: 50),
                child: _buildUpdateInfoCard(),
              ),
              const SizedBox(height: 24),
              AnimateEntry(
                delay: const Duration(milliseconds: 150),
                child: _buildPasswordCard(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Layout Mobile (Single Scrollable Column) ---
  Widget _buildMobileLayout() {
    return Column(
      children: [
        AnimateEntry(
          delay: Duration.zero,
          child: _buildAvatarCard(),
        ),
        const SizedBox(height: 16),
        AnimateEntry(
          delay: const Duration(milliseconds: 50),
          child: _buildSettingsCard(),
        ),
        const SizedBox(height: 16),
        AnimateEntry(
          delay: const Duration(milliseconds: 100),
          child: _buildUpdateInfoCard(),
        ),
        const SizedBox(height: 16),
        AnimateEntry(
          delay: const Duration(milliseconds: 150),
          child: _buildPasswordCard(),
        ),
      ],
    );
  }

  // --- Component Cards ---

  Widget _buildAvatarCard() {
    final String name = _profile['name'] ?? '-';
    final String username = _profile['username'] ?? '-';
    final String role = _profile['role'] ?? '-';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // Elegant Interactive Avatar with Camera Badge
          ScaleOnTap(
            onTap: _showPhotoOptions,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: _storedPhotoBase64 != null
                        ? null
                        : LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _storedPhotoBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.memory(
                            base64Decode(_storedPhotoBase64!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).cardColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Theme.of(context).cardColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Elegant Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan & Preferensi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Elegant Switch Mode Gelap
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              final isDark = currentMode == ThemeMode.dark;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFFFBBF24) : Theme.of(context).colorScheme.primary)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? const Color(0xFFFBBF24) : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mode Gelap',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            isDark ? 'Ganti ke tema terang' : 'Ganti ke tema gelap',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) {
                        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Form(
        key: _infoFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ubah Informasi Akun',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Name Field
            const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Masukkan nama lengkap Anda...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nama lengkap wajib diisi.';
                if (v.trim().length < 2) return 'Nama minimal mengandung 2 karakter.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Username Field
            const Text('Username', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: _inputDecoration('Masukkan username Anda...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Username wajib diisi.';
                if (v.trim().length < 3) return 'Username minimal mengandung 3 karakter.';
                if (v.trim().length > 16) return 'Username maksimal mengandung 16 karakter.';
                final regex = RegExp(r'^[a-z0-9_]+$');
                if (!regex.hasMatch(v.trim())) {
                  return 'Hanya boleh berisi huruf kecil, angka, dan underscore (_).';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ScaleOnTap(
                onTap: _isUpdatingInfo ? null : _updateProfileInfo,
                child: ElevatedButton(
                  onPressed: null, // Handled by ScaleOnTap
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isUpdatingInfo
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Form(
        key: _passwordFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Keamanan Akun & Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Current Password
            const Text('Password Saat Ini', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: _inputPasswordDecoration(
                'Masukkan password saat ini...',
                _obscureCurrent,
                () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password saat ini wajib diisi.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // New Password
            const Text('Password Baru', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: _inputPasswordDecoration(
                'Masukkan password baru minimal 6 karakter...',
                _obscureNew,
                () => setState(() => _obscureNew = !_obscureNew),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password baru wajib diisi.';
                if (v.length < 6) return 'Password baru minimal 6 karakter.';
                if (v == _currentPasswordController.text) {
                  return 'Password baru tidak boleh sama dengan password saat ini.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Confirm Password
            const Text('Konfirmasi Password Baru', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: _inputPasswordDecoration(
                'Masukkan kembali password baru...',
                _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi password baru wajib diisi.';
                if (v != _newPasswordController.text) {
                  return 'Konfirmasi password tidak cocok dengan password baru.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ScaleOnTap(
                onTap: _isUpdatingPassword ? null : _updatePassword,
                child: ElevatedButton(
                  onPressed: null, // Handled by ScaleOnTap
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isUpdatingPassword
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Perbarui Password', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
      ),
    );
  }

  InputDecoration _inputPasswordDecoration(String hint, bool obscure, VoidCallback toggleObscure) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
        onPressed: toggleObscure,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
      ),
    );
  }
}
