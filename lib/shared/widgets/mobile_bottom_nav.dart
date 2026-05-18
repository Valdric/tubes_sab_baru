import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';
import 'package:gosir/features/categories/screens/categories_screen.dart';
import 'package:gosir/features/menus/screens/menus_screen.dart';
import 'package:gosir/features/ingredients/screens/ingredients_screen.dart';
import 'package:gosir/features/orders/screens/orders_screen.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  const MobileBottomNav({super.key, required this.currentIndex});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.label_outline),
        activeIcon: Icon(Icons.label),
        label: 'Kategori',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu),
        activeIcon: Icon(Icons.restaurant_menu),
        label: 'Menu',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        activeIcon: Icon(Icons.inventory_2),
        label: 'Inventaris',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long),
        label: 'Pesanan',
      ),
    ];

    // Ensure index is always within valid range to prevent crashes
    final int safeIndex = (currentIndex >= 0 && currentIndex < items.length) ? currentIndex : 0;

    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            _navigateTo(context, const DashboardScreen());
            break;
          case 1:
            _navigateTo(context, const CategoriesScreen());
            break;
          case 2:
            _navigateTo(context, const MenusScreen());
            break;
          case 3:
            _navigateTo(context, const IngredientsScreen());
            break;
          case 4:
            _navigateTo(context, const OrdersScreen());
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.mutedForeground,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: items,
    );
  }
}
