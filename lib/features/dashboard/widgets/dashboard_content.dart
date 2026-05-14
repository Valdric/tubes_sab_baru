import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';

// Import layar tujuan navigasi
import 'package:tubes_ppm_sab/features/reports/screens/reports_screen.dart';
import 'package:tubes_ppm_sab/features/history/screens/history_screen.dart';
import 'package:tubes_ppm_sab/features/inventory/screens/inventory_screen.dart';
import 'package:tubes_ppm_sab/features/cashier/screens/cashier_screen.dart';
import 'package:tubes_ppm_sab/core/services/api_service.dart';

// --- DATA SINKRONISASI ---
// Data ini akan diisi setelah login berhasil
class UserData {
  static String name = "";
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool _isLoading = true;

  String todaySales = "0.00";
  String openOrders = "0";
  String lowStockCount = "0";
  List<String> lowStockNames = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await ApiService().get('/reports/dashboard');

      if (mounted) {
        setState(() {
          // Sync with API structure: response['data']['revenue']['value'], etc.
          final data = response['data'];
          if (data != null) {
            todaySales = data['revenue']['value']?.toString() ?? "0.00";
            openOrders = data['total_orders']['value']?.toString() ?? "0";
            
            final lowStockItems = data['low_stock_items'] as List?;
            lowStockCount = (lowStockItems?.length ?? 0).toString();
            lowStockNames = lowStockItems
                    ?.map((item) => "${item['name']} (${item['stock']} ${item['unit']} remaining)")
                    .take(2)
                    .toList()
                    .cast<String>() ??
                [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final subtitleColor = isDark ? Colors.white70 : AppColors.onSurfaceVariant;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SINKRON: Nama ambil dari UserData, bukan teks manual lagi
        Text('Good morning, ${UserData.name.isEmpty ? 'User' : UserData.name}', style: textTheme.displayLarge),
        const SizedBox(height: 4),
        Text('Manage your business at a glance.', style: textTheme.bodyLarge),
        const SizedBox(height: 16),

        // Bento Grid: Quick Stats (Dibuat lebih rapat/pipih sesuai request sebelumnya)
        GridView.count(
          crossAxisCount: isDesktop ? 3 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isDesktop ? 1.5 : 2.1,
          children: [
            _buildStatCard(
              context,
              title: "TODAY'S SALES",
              value: "\$$todaySales",
              icon: Icons.trending_up,
              iconColor: AppColors.primary,
              isDark: isDark,
              bottomWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('↑ 12% vs yesterday', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReportsScreen())),
            ),
            _buildStatCard(
              context,
              title: "OPEN ORDERS",
              value: openOrders,
              icon: Icons.receipt_long,
              iconColor: AppColors.secondary,
              isDark: isDark,
              bottomWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.outlineVariant.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                child: Text('4 pending payment', style: TextStyle(color: subtitleColor, fontSize: 12)),
              ),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
            ),
            _buildStatCard(
              context,
              title: "LOW STOCK ALERTS",
              value: lowStockCount,
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.error,
              valueColor: AppColors.error,
              isDark: isDark,
              bottomWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: lowStockNames.isEmpty
                    ? [Text('All items in stock', style: TextStyle(color: subtitleColor, fontSize: 11))]
                    : lowStockNames
                        .map((name) => Text('• $name',
                            style: TextStyle(color: subtitleColor, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis))
                        .toList(),
              ),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InventoryScreen())),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // MAIN MENU SECTION (Layout Grid Ikon)
        Text('Main Menu', style: textTheme.displayMedium),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _buildMainMenuButton(context, icon: Icons.point_of_sale, label: 'Cashier', isDark: isDark, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CashierScreen()))),
            _buildMainMenuButton(context, icon: Icons.history, label: 'History', isDark: isDark, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen()))),
            _buildMainMenuButton(context, icon: Icons.inventory_2, label: 'Inventory', isDark: isDark, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InventoryScreen()))),
            _buildMainMenuButton(context, icon: Icons.analytics, label: 'Reports', isDark: isDark, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReportsScreen()))),
            _buildMainMenuButton(context, icon: Icons.restaurant_menu, label: 'Menu', isDark: isDark, onTap: () {}),
            _buildMainMenuButton(context, icon: Icons.category, label: 'Category', isDark: isDark, onTap: () {}),
            _buildMainMenuButton(context, icon: Icons.people, label: 'Staff', isDark: isDark, onTap: () {}),
            _buildMainMenuButton(context, icon: Icons.settings, label: 'Settings', isDark: isDark, onTap: () {}),
          ],
        ),
      ],
    );
  }

  // --- UI COMPONENTS HELPER ---

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color iconColor, Color? valueColor, Widget? bottomWidget, required bool isDark, required VoidCallback onTap}) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurface;
    final priceStyle = GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor ?? textColor);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2, fontSize: 10, color: textColor)),
                          Icon(icon, color: iconColor, size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(value, style: priceStyle),
                      if (bottomWidget != null) ...[
                        const Spacer(),
                        bottomWidget,
                      ]
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.outlineVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainMenuButton(BuildContext context, {required IconData icon, required String label, required bool isDark, VoidCallback? onTap}) {
    final textColor = isDark ? Colors.white : AppColors.onSurface;
    final iconBgColor = isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}