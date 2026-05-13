import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/profile/screens/profile_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 2)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('History', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
          if (isDesktop) const Sidebar(currentIndex: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildStatRow(),
                const SizedBox(height: 24),
                const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildOrderItem('#ORD-089', '2x Cappuccino...', '\$18.50', 'Paid', true),
                _buildOrderItem('#ORD-088', '1x Espresso...', '\$12.00', 'Paid', true),
                _buildOrderItem('#ORD-087', '4x Iced Latte...', '\$32.00', 'Cancelled', false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 2),
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(child: _buildMiniStat('Total Orders', '142', Icons.receipt_long, AppColors.surfaceContainerLowest, AppColors.onSurface)),
        const SizedBox(width: 12),
        Expanded(child: _buildMiniStat('Revenue', '\$3,450', Icons.payments, AppColors.primary, AppColors.onPrimary)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String val, IconData icon, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: text.withOpacity(0.7), size: 20),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
          Text(label, style: TextStyle(fontSize: 12, color: text.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String id, String desc, String price, String status, bool success) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: success ? AppColors.primary : AppColors.error, width: 4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(id, style: const TextStyle(fontWeight: FontWeight.bold)), Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant))]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(price, style: const TextStyle(fontWeight: FontWeight.bold)), Text(status, style: TextStyle(color: success ? AppColors.primary : AppColors.error, fontWeight: FontWeight.bold, fontSize: 12))]),
        ],
      ),
    );
  }
}