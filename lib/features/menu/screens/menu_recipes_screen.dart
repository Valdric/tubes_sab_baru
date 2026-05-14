import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/core/services/api_service.dart';

class MenuRecipesScreen extends StatefulWidget {
  const MenuRecipesScreen({super.key});

  @override
  State<MenuRecipesScreen> createState() => _MenuRecipesScreenState();
}

class _MenuRecipesScreenState extends State<MenuRecipesScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _menus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/menus');
      if (mounted) {
        setState(() {
          if (response is List) {
            _menus = response;
          } else if (response is Map && response['data'] != null) {
            _menus = response['data'] is List ? response['data'] : (response['data']['items'] ?? []);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load menu: $e')));
      }
    }
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _menus.isEmpty
                    ? const Center(child: Text('No menu items found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _menus.length,
                        itemBuilder: (context, index) {
                          final menu = _menus[index];
                          return _recipeCard(
                            menu['name'] ?? 'No Name',
                            menu['category']?['name'] ?? 'No Category',
                            'N/A', // Time not usually in menu table
                            menu['description'] ?? 'No description provided.',
                          );
                        },
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
              Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
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
