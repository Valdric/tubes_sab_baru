import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/features/profile/screens/profile_screen.dart';
import 'package:gosir/features/dashboard/widgets/dashboard_content.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Fungsi untuk navigasi ke profile dan refresh saat kembali
  Future<void> _goToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
    // Refresh UI dashboard (seperti nama user) saat kembali dari profile
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,

      // 1. DRAWER (SIDEBAR KIRI UNTUK MOBILE)
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 0)) : null,

      // 2. APPBAR
      appBar: isDesktop ? null : AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'LumiPOS',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: _goToProfile,
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
            ),
          ),
        ],
      ),

      // 3. BODY
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 0),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: DashboardContent(),
            ),
          ),
        ],
      ),

      // 4. BOTTOM NAVIGATION
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }
}
