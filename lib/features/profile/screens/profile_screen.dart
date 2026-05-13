import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      // Drawer untuk HP agar sidebar bisa ditarik dari kiri
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 8)) : null,

      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Profile Settings',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    const Text(
                      'Profile Settings',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  if (isDesktop) const SizedBox(height: 32),

                  // Profile Photo Section
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAiLvIgC4oqL022lsgqEF_u7vzMRmcEqGIW3VSUW9eDF6myqs7GGK19vZeJoXd8AjDQkWOqbK20Ot_zBBoIIIPs9xToIpJexqsarqtkN3bHCCbd9kalyVb_UrcNWTt7rqx-JrJ4WQeWDYmhbGpv3aUVKZGaF05DW3ETqV14mCa83SaZI7D7HnNXWd_ZSlup_lVEaPmHjqVO49s8FmcYRExD_zloybjYeXNxIQjliIgoy2GGuH01BRA2kPSh2-CO-QYxKdyhnSmabMqG'),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Change Photo'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Account Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildProfileField('Full Name', 'Sarah Jenkins'),
                  _buildProfileField('Email Address', 'sarah.j@lumipos.com'),
                  _buildProfileField('Employee ID', 'EMP-402-08'),
                  _buildProfileField('Role', 'Store Manager (Admin)'),
                  _buildProfileField('Branch', 'Branch #402 - Downtown'),

                  const SizedBox(height: 24),
                  const Text(
                    'Security',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text('Change Password', style: TextStyle(color: AppColors.onSurface)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text('Save Changes', style: TextStyle(color: AppColors.onPrimary)),
                    ),
                  ),

                  // BAGIAN LOGOUT YANG UDAH DIDEMPETIN
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                      label: const Text(
                        'Logout Account',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: -1),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}