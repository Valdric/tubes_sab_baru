import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/profile/screens/profile_screen.dart';
import 'package:tubes_ppm_sab/features/dashboard/widgets/dashboard_content.dart'; // Import konten dashboard

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    // Cek status dark mode biar background nyesuain
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,

      // 1. DRAWER (SIDEBAR KIRI UNTUK MOBILE)
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 0)) : null,

      // 2. APPBAR SAMA KAYA CASHIER
      appBar: isDesktop ? null : AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'LumiPOS', // Atau lu bisa ganti jadi 'Dashboard'
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        // Tombol Hamburger Menu dibungkus Builder biar bisa manggil Drawer
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
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen())
              ),
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAebimc9BJtwloOpY4j3Hwdhm0j-EIy2iiW2CJ0maPC0ynBmA_zCVpSSjaDMuEHEOJcCN51Od4Hadfzzk_XFBW5sZ9g3S6NSfet_46wnnjChcC_agRNK38d5OIyXw7k-GcYERvIB3mG99bNXGtl7w6fbQO4vm6E41_3PyzbPBgY7hddAPSGq1TA8abykcXUvJDQrYjGHz6DpcACh4LwxiV7gMHlhVa1sTbnC9Po_RDVQ5amXn3dbVomw4pyhxCHJpaBLG3U9HmKvdqk'),
              ),
            ),
          ),
        ],
      ),

      // 3. BODY (GABUNGAN SIDEBAR DESKTOP & KONTEN)
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar tampil langsung kalau di Desktop/Tablet
          if (isDesktop) const Sidebar(currentIndex: 0),

          // Konten Dashboard yang kemaren udah kita benerin dark mode-nya
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: DashboardContent(),
            ),
          ),
        ],
      ),

      // 4. BOTTOM NAVIGATION UNTUK MOBILE
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }
}