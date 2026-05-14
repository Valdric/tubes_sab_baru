import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/features/auth/screens/login_screen.dart';
import 'package:tubes_ppm_sab/features/profile/screens/edit_profile_screen.dart';
import 'package:tubes_ppm_sab/features/profile/screens/change_password_screen.dart';
import 'package:tubes_ppm_sab/core/services/api_service.dart';
import 'package:tubes_ppm_sab/main.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/dashboard/widgets/dashboard_content.dart'; // Buat sinkron nama ke dashboard

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  bool _isDarkMode = false;
  bool _isLoading = true;

  // Variabel Penampung Data Profil
  String _fullName = "";
  String _username = "";
  String _role = "";

  // Logic Gambar: Pake network image default kalau belum ada lokal path
  String _currentImagePath = "";

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/profile');
      if (mounted) {
        final data = response['data'];
        setState(() {
          _fullName = data['name'] ?? "";
          _username = data['username'] ?? "";
          _role = data['role'] ?? "";
          
          // Update Global UserData biar Dashboard ikutan ganti
          UserData.name = _fullName;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of LumiPOS?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.surface;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: -1)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.onSurfaceVariant),
        title: Text('Profile Settings', style: GoogleFonts.hankenGrotesk(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: -1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // FIXED: LOGIC TAMPILAN GAMBAR DARI LOKAL MAUPUN NETWORK
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage: _currentImagePath.isEmpty
                            ? null
                            : (_currentImagePath.startsWith('http')
                                ? NetworkImage(_currentImagePath)
                                : FileImage(File(_currentImagePath))
                                    as ImageProvider),
                        child: _currentImagePath.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(_fullName, style: GoogleFonts.hankenGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                      Text('@$_username', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                      const SizedBox(height: 12),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(_role, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11))
                      ),

                      _buildSectionHeader('Account'),

                      _buildSettingsTile(
                          Icons.person_outline,
                          'Edit Profile',
                          cardColor,
                          textColor,
                          onTap: () async {
                            // NAVIGASI KE EDIT PROFILE DAN TUNGGU HASILNYA
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  currentName: _fullName,
                                  currentEmail: _username, // We use username as the unique ID field in UI
                                  currentImagePath: _currentImagePath,
                                ),
                              ),
                            );

                            // JIKA USER KLIK SAVE, REFRESH DATA DARI API
                            if (result == true) {
                              _fetchProfileData();
                            }
                          }
                      ),

                      _buildSettingsTile(
                        Icons.lock_outline,
                        'Change Password',
                        cardColor,
                        textColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                          );
                        },
                      ),

                      _buildSectionHeader('Appearance'),
                      _buildSwitchTile(icon: Icons.dark_mode_outlined, title: 'Dark Mode', value: _isDarkMode, cardColor: cardColor, textColor: textColor, onChanged: (val) {
                        setState(() => _isDarkMode = val);
                        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      }),

                      _buildSectionHeader('Store Options'),
                      _buildSettingsTile(Icons.storefront, 'Branch Information', cardColor, textColor),
                      _buildSettingsTile(Icons.print_outlined, 'Printer Setup', cardColor, textColor),

                      const SizedBox(height: 32),
                      SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                              onPressed: () => _handleLogout(context),
                              icon: const Icon(Icons.logout, color: AppColors.error),
                              label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error.withValues(alpha: 0.1), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
                          )
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: -1),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4), child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13))));
  }

  Widget _buildSettingsTile(IconData icon, String title, Color cardColor, Color textColor, {VoidCallback? onTap}) {
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
        child: ListTile(
            leading: Icon(icon, color: AppColors.onSurface, size: 22),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: onTap
        )
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required Color cardColor, required Color textColor, required ValueChanged<bool> onChanged}) {
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
        child: SwitchListTile(
            secondary: Icon(icon, color: AppColors.onSurface, size: 22),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 14)),
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged
        )
    );
  }
}