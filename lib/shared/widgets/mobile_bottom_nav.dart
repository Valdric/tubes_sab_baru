import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';
import 'package:gosir/features/cashier/screens/cashier_screen.dart';
import 'package:gosir/features/history/screens/history_screen.dart';
import 'package:gosir/features/inventory/screens/inventory_screen.dart';
import 'package:gosir/features/reports/screens/reports_screen.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;

  const MobileBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    // Nyesuain background navbar kalau Dark Mode nyala
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Bagi jarak sama rata
            children: [
              // Semua menu dikirim ke fungsi helper di bawah
              _buildNavItem(context, icon: Icons.dashboard, label: 'Dashboard', index: 0, target: const DashboardScreen()),
              _buildNavItem(context, icon: Icons.point_of_sale, label: 'Cashier', index: 1, target: const CashierScreen()),
              _buildNavItem(context, icon: Icons.history, label: 'History', index: 2, target: const HistoryScreen()),
              _buildNavItem(context, icon: Icons.inventory_2, label: 'Inventory', index: 3, target: const InventoryScreen()),
              _buildNavItem(context, icon: Icons.analytics, label: 'Reports', index: 4, target: const ReportsScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required Widget target}) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? Colors.white54 : AppColors.onSurfaceVariant;

    return Expanded( // PENTING 1: Pake Expanded biar ga overflow dan bagi space adil
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            // Pake PageRouteBuilder biar pindah halaman gak ada animasi nge-slide
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => target,
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), // Padding horizontal sedikit dikecilin
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20), // Bikin bentuk lonjong khas Material 3
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: FittedBox( // PENTING 2: Biar teks mengecil otomatis kalau layar HP sempit
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: 11, // Ukuran font diturunin dikit
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
