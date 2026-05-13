import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';

class MenuRecipesScreen extends StatelessWidget {
  const MenuRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 5)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Menu & Recipes', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
      ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 5),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (isDesktop) const Text('Menu & Recipes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                if (isDesktop) const SizedBox(height: 24),
                _recipeCard('Double Shot Espresso', 'Coffee', '4 mins', 'High intensity espresso with rich crema.'),
                _recipeCard('Caramel Macchiato', 'Coffee', '6 mins', 'Vanilla-marked milk with espresso and caramel.'),
                _recipeCard('Classic Croissant', 'Bakery', '2 mins', 'Buttery, flaky French pastry served warm.'),
                _recipeCard('Matcha Latte', 'Non-Coffee', '5 mins', 'Premium ceremonial matcha with steamed milk.'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: -1),
    );
  }

  Widget _recipeCard(String name, String cat, String time, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.restaurant_menu, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            Row(children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(time, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ]),
          ]),
        ],
      ),
    );
  }
}