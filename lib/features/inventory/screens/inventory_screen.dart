import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/profile/screens/profile_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      // 1. Tambahin Drawer biar Sidebar muncul pas ditarik/diklik di HP
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 3)) : null,

      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: Text(
          'Inventory',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // 2. Bungkus pake Builder biar tombol Menu bisa fungsi
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
          if (isDesktop) const Sidebar(currentIndex: 3),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (isDesktop) const Text('Inventory Stock', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                if (isDesktop) const SizedBox(height: 24),

                _buildStockItem('Almond Milk', 'Dairy', '2 Liters', 'Low Stock', AppColors.error),
                _buildStockItem('Espresso Beans', 'Coffee', '1 Kilogram', 'Low Stock', AppColors.error),
                _buildStockItem('Oat Milk', 'Dairy', '15 Liters', 'In Stock', AppColors.primary),
                _buildStockItem('Croissant Dough', 'Bakery', '40 Pcs', 'In Stock', AppColors.primary),
                _buildStockItem('Paper Cups (12oz)', 'Packaging', '250 Pcs', 'In Stock', AppColors.primary),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 3),
    );
  }

  Widget _buildStockItem(String name, String cat, String qty, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(cat, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(qty, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}