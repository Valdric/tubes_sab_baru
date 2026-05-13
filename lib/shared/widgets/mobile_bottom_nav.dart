import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/features/dashboard/screens/dashboard_screen.dart';
import 'package:tubes_ppm_sab/features/cashier/screens/cashier_screen.dart';
import 'package:tubes_ppm_sab/features/history/screens/history_screen.dart';
import 'package:tubes_ppm_sab/features/inventory/screens/inventory_screen.dart';
import 'package:tubes_ppm_sab/features/reports/screens/reports_screen.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;

  const MobileBottomNav({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(context, icon: Icons.dashboard, label: 'Dashboard', index: 0, target: const DashboardScreen()),
          _buildBottomNavItem(context, icon: Icons.point_of_sale, label: 'Cashier', index: 1, target: const CashierScreen()),
          _buildBottomNavItem(context, icon: Icons.history, label: 'History', index: 2, target: const HistoryScreen()),
          _buildBottomNavItem(context, icon: Icons.inventory_2, label: 'Inventory', index: 3, target: const InventoryScreen()),
          _buildBottomNavItem(context, icon: Icons.analytics, label: 'Reports', index: 4, target: const ReportsScreen()),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, {required IconData icon, required String label, required int index, required Widget target}) {
    bool isActive = currentIndex == index;
    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, animation1, animation2) => target, transitionDuration: Duration.zero));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive ? BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(24)) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}