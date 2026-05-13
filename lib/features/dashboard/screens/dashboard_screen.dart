import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/dashboard/widgets/dashboard_content.dart';
import 'package:tubes_ppm_sab/features/profile/screens/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 0)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('LumiPOS', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAebimc9BJtwloOpY4j3Hwdhm0j-EIy2iiW2CJ0maPC0ynBmA_zCVpSSjaDMuEHEOJcCN51Od4Hadfzzk_XFBW5sZ9g3S6NSfet_46wnnjChcC_agRNK38d5OIyXw7k-GcYERvIB3mG99bNXGtl7w6fbQO4vm6E41_3PyzbPBgY7hddAPSGq1TA8abykcXUvJDQrYjGHz6DpcACh4LwxiV7gMHlhVa1sTbnC9Po_RDVQ5amXn3dbVomw4pyhxCHJpaBLG3U9HmKvdqk')),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 0),
          const Expanded(child: SingleChildScrollView(padding: EdgeInsets.all(24), child: DashboardContent())),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }
}