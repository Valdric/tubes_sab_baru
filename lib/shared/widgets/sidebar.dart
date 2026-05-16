import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/features/auth/screens/login_screen.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';
import 'package:gosir/features/cashier/screens/cashier_screen.dart';
import 'package:gosir/features/history/screens/history_screen.dart';
import 'package:gosir/features/inventory/screens/inventory_screen.dart';
import 'package:gosir/features/reports/screens/reports_screen.dart';
import 'package:gosir/features/profile/screens/profile_screen.dart';

// IMPORT MENU BARU YANG TADI DIBIKIN
import 'package:gosir/features/menu/screens/menu_recipes_screen.dart';
import 'package:gosir/features/categories/screens/categories_screen.dart';
import 'package:gosir/features/staff/screens/staff_management_screen.dart';
import 'package:gosir/features/dashboard/widgets/dashboard_content.dart';

class Sidebar extends StatelessWidget {
  final int currentIndex;
  const Sidebar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      color: AppColors.surfaceBright,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profil - Klik untuk ke Profile
          InkWell(
            onTap: () => _navigate(context, const ProfileScreen(), 8),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(UserData.name.isEmpty ? 'User' : UserData.name,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        const Text('Administrator',
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _navItem(context, Icons.dashboard, 'Dashboard', 0, const DashboardScreen()),
                _navItem(context, Icons.point_of_sale, 'Cashier', 1, const CashierScreen()),
                _navItem(context, Icons.history, 'History', 2, const HistoryScreen()),
                _navItem(context, Icons.inventory_2, 'Inventory', 3, const InventoryScreen()),
                _navItem(context, Icons.analytics, 'Reports', 4, const ReportsScreen()),

                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.outlineVariant)
                ),

                _navItem(context, Icons.restaurant_menu, 'Menu & Recipes', 5, const MenuRecipesScreen()),
                _navItem(context, Icons.category, 'Categories', 6, const CategoriesScreen()),
                _navItem(context, Icons.people, 'Staff Management', 7, const StaffManagementScreen()),
                _navItem(context, Icons.settings, 'Profile Settings', 8, const ProfileScreen()),
              ],
            ),
          ),

          // Tombol Logout
          _navItem(
            context,
            Icons.logout,
            'Logout',
            -1,
            null,
            isError: true,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _navigate(BuildContext context, Widget target, int index) {
    if (currentIndex != index) {
      // Tutup drawer dulu kalau di mobile sebelum pindah page
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.pop(context);
      }
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => target,
          transitionDuration: Duration.zero, // Biar transisi antar menu instan & smooth
        ),
      );
    }
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index, Widget? target, {bool isError = false, VoidCallback? onTap}) {
    bool isActive = currentIndex == index;
    Color color = isError ? AppColors.error : (isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8)
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(
            label,
            style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14
            )
        ),
        onTap: onTap ?? () {
          if (target != null) {
            _navigate(context, target, index);
          }
        },
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
