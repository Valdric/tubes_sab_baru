import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';

// IMPORT SCREEN BARU DISINI
import 'package:tubes_ppm_sab/features/cashier/screens/cashier_screen.dart';
import 'package:tubes_ppm_sab/features/inventory/screens/inventory_screen.dart';
import 'package:tubes_ppm_sab/features/reports/screens/reports_screen.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Section
        Text('Good morning, Valdric', style: textTheme.displayLarge),
        const SizedBox(height: 8),
        Text('Here\'s what\'s happening at Branch #402 today.', style: textTheme.bodyLarge),
        const SizedBox(height: 40),

        // Bento Grid: Quick Stats
        GridView.count(
          crossAxisCount: isDesktop ? 3 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.5 : 2.0,
          children: [
            _buildStatCard(
              context,
              title: "TODAY'S SALES",
              value: "\$3,245.50",
              icon: Icons.trending_up,
              iconColor: AppColors.primary,
              bottomWidget: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.tertiaryFixedDim.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward, size: 14, color: AppColors.tertiaryContainer),
                        const SizedBox(width: 4),
                        Text('12%', style: textTheme.labelSmall?.copyWith(color: AppColors.tertiaryContainer)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('vs yesterday', style: textTheme.bodyMedium?.copyWith(fontSize: 14)),
                ],
              ),
            ),
            _buildStatCard(
              context,
              title: "OPEN ORDERS",
              value: "14",
              icon: Icons.receipt_long,
              iconColor: AppColors.secondary,
              bottomWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(4)),
                child: Text('4 pending payment', style: textTheme.labelSmall),
              ),
            ),
            _buildStatCard(
              context,
              title: "LOW STOCK ALERTS",
              value: "3",
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.error,
              valueColor: AppColors.error,
              bottomWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Almond Milk (2L remaining)', style: textTheme.bodyMedium?.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
                  Text('• Espresso Beans (1kg remaining)', style: textTheme.bodyMedium?.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Quick Actions
        Text('Quick Actions', style: textTheme.displayMedium),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            // TOMBOL-TOMBOL INI SUDAH DISAMBUNGKAN NAVIGASINYA
            _buildQuickActionButton(
                context,
                icon: Icons.point_of_sale,
                label: 'New Order',
                isPrimary: true,
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CashierScreen()));
                }
            ),
            _buildQuickActionButton(
                context,
                icon: Icons.analytics,
                label: 'Daily Report',
                iconColor: AppColors.primary,
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
                }
            ),
            _buildQuickActionButton(
                context,
                icon: Icons.inventory_2,
                label: 'Inventory Check',
                iconColor: AppColors.secondary,
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
                }
            ),
            _buildQuickActionButton(
                context,
                icon: Icons.table_restaurant,
                label: 'Table Map',
                iconColor: AppColors.tertiary,
                onTap: () {
                  // Biarkan kosong dulu karena belum ada Table Map Screen
                }
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
    required Widget bottomWidget,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final priceStyle = GoogleFonts.hankenGrotesk(fontSize: 28, fontWeight: FontWeight.bold, height: 32 / 28, color: valueColor ?? AppColors.onSurface);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
              Icon(icon, color: iconColor),
            ],
          ),
          Text(value, style: priceStyle),
          bottomWidget,
        ],
      ),
    );
  }

  // TAMBAHKAN PARAMETER onTap DISINI
  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, bool isPrimary = false, Color? iconColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap, // SAMBUNGKAN PARAMETER DISINI
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: isPrimary ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isPrimary ? AppColors.onPrimary : iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isPrimary ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}