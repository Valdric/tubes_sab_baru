import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/profile/screens/profile_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      // 1. Drawer wajib ada biar Sidebar bisa ditarik di HP
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 4)) : null,

      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: Text(
          'Reports',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // 2. Builder wajib ada biar fungsi openDrawer() jalan pas diklik
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAebimc9BJtwloOpY4j3Hwdhm0j-EIy2iiW2CJ0maPC0ynBmA_zCVpSSjaDMuEHEOJcCN51Od4Hadfzzk_XFBW5sZ9g3S6NSfet_46wnnjChcC_agRNK38d5OIyXw7k-GcYERvIB3mG99bNXGtl7w6fbQO4vm6E41_3PyzbPBgY7hddAPSGq1TA8abykcXUvJDQrYjGHz6DpcACh4LwxiV7gMHlhVa1sTbnC9Po_RDVQ5amXn3dbVomw4pyhxCHJpaBLG3U9HmKvdqk'),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) const Text('Sales Reports', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  if (isDesktop) const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _reportCard('Daily Revenue', '\$3,245.50', Icons.payments)),
                      const SizedBox(width: 16),
                      Expanded(child: _reportCard('Avg. Order', '\$24.84', Icons.analytics)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 64, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('Sales Trend Chart', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Data visualization will appear here', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 4),
    );
  }

  Widget _reportCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.onPrimaryContainer, size: 28),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.onPrimaryContainer, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}