import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 6)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Categories', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
      ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 6),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(24),
              crossAxisCount: isDesktop ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _categoryCard('Coffee', Icons.coffee, '12 items'),
                _categoryCard('Non-Coffee', Icons.local_drink, '8 items'),
                _categoryCard('Bakery', Icons.bakery_dining, '15 items'),
                _categoryCard('Dessert', Icons.cake, '6 items'),
                _categoryCard('Main Course', Icons.restaurant, '10 items'),
                _categoryCard('Merchandise', Icons.shopping_bag, '4 items'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String title, IconData icon, String count) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(count, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}