import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/auth/screens/login_screen.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';
import 'package:gosir/features/profile/screens/profile_screen.dart';
import 'package:gosir/features/categories/screens/categories_screen.dart';
import 'package:gosir/features/menus/screens/menus_screen.dart';
import 'package:gosir/features/ingredients/screens/ingredients_screen.dart';
import 'package:gosir/features/orders/screens/orders_screen.dart';
import 'package:gosir/features/reports/screens/reports_screen.dart';
import 'package:gosir/features/cashes/screens/cashes_screen.dart';
import 'package:gosir/features/staff/screens/staff_management_screen.dart';
import 'package:gosir/features/cashier/screens/cashier_screen.dart';

class Sidebar extends StatefulWidget {
  final int currentIndex;
  const Sidebar({super.key, required this.currentIndex});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final ApiService _api = ApiService();
  String _role = 'CASHIER'; // Default role
  String? _storedPhotoBase64;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final res = await _api.get('/auth/me');
      if (mounted) {
        final username = res['data']['username'] ?? '';
        setState(() {
          _role = res['data']['role'] ?? 'CASHIER';
        });
        if (username.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final photo = prefs.getString('profile_photo_$username');
          if (mounted) {
            setState(() {
              _storedPhotoBase64 = photo;
            });
          }
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = _role.toUpperCase() == 'SUPERADMIN';
    final isAdmin = _role.toUpperCase() == 'ADMIN';
    final isStaff = isSuperAdmin || isAdmin;

    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E2923) // Subtle dark slate border that integrates perfectly in dark mode
                : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4), // Subtle soft border in light mode
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.store, color: Theme.of(context).cardColor, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GoSir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: _storedPhotoBase64 != null
                      ? CircleAvatar(
                          radius: 12,
                          backgroundImage: MemoryImage(base64Decode(_storedPhotoBase64!)),
                        )
                      : Icon(Icons.account_circle_outlined, color: Theme.of(context).colorScheme.onSurface),
                  tooltip: 'Profil Saya',
                  onPressed: () => _navigateTo(context, const ProfileScreen()),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8, top: 8),
                  child: Text(
                    'MANAGEMENT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _navItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  index: 0,
                  onTap: () => _navigateTo(context, const DashboardScreen()),
                ),
                _navItem(
                  icon: Icons.label_outline,
                  label: 'Kategori',
                  index: 1,
                  onTap: () => _navigateTo(context, const CategoriesScreen()),
                ),
                _navItem(
                  icon: Icons.restaurant_menu,
                  label: 'Menu',
                  index: 2,
                  onTap: () => _navigateTo(context, const MenusScreen()),
                ),
                _navItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Bahan Baku',
                  index: 3,
                  onTap: () => _navigateTo(context, const IngredientsScreen()),
                ),
                _navItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Pesanan',
                  index: 4,
                  onTap: () => _navigateTo(context, const OrdersScreen()),
                ),
                _navItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Catatan Kas',
                  index: 5,
                  onTap: () => _navigateTo(context, const CashesScreen()),
                ),
                if (isStaff)
                  _navItem(
                    icon: Icons.people_outline,
                    label: 'Staff Pegawai',
                    index: 6,
                    onTap: () => _navigateTo(context, const StaffManagementScreen()),
                  ),
                _navItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Laporan',
                  index: 7,
                  onTap: () => _navigateTo(context, const ReportsScreen()),
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CashierScreen()),
                    );
                  },
                  icon: Icon(Icons.storefront, size: 20),
                  label: Text('Mode Kasir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await _api.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: Icon(Icons.logout, size: 20, color: Theme.of(context).colorScheme.error),
                  label: Text(
                    'Keluar',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = widget.currentIndex == index;
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        tileColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08) : null,
      ),
    );
  }
}
