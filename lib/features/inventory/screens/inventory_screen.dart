import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/features/profile/screens/profile_screen.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/inventory/screens/inventory_form_screen.dart'; // Import Form

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _inventoryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  // AMBIL DATA DARI BACKEND
  Future<void> _fetchInventory() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/ingredients');

      if (mounted) {
        setState(() {
          // Sync with API structure: response['data']['items']
          if (response is Map && response['data'] != null && response['data']['items'] != null) {
            _inventoryItems = response['data']['items'];
          } else if (response is List) {
            _inventoryItems = response;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _inventoryItems = [];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load ingredients: $e')));
      }
    }
  }

  // FUNGSI DELETE DENGAN KONFIRMASI
  Future<void> _deleteItem(String id) async { // ID is String in API
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this ingredient?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.delete('/ingredients/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingredient deleted!')));
        _fetchInventory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _navigateToForm([Map<String, dynamic>? item]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryFormScreen(item: item),
      ),
    );

    if (result == true) {
      _fetchInventory(); // Refresh data jika ada perubahan
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 3)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Inventory', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu_open, color: AppColors.primary), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: const CircleAvatar(radius: 18, backgroundColor: AppColors.surfaceContainerHigh, child: Icon(Icons.person, size: 20)),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 3),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchInventory,
              color: AppColors.primary,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _inventoryItems.isEmpty
                      ? const Center(child: Text('No items found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _inventoryItems.length,
                          itemBuilder: (context, index) {
                            final item = _inventoryItems[index];
                            final stockValue = double.tryParse(item['stock']?.toString() ?? '0') ?? 0;
                            final thresholdValue = double.tryParse(item['threshold']?.toString() ?? '0') ?? 0;
                            final isLowStock = stockValue <= thresholdValue;
                            
                            return InkWell(
                              onTap: () => _navigateToForm(item), // Edit Item
                              child: _buildStockItem(
                                id: item['id'].toString(),
                                name: item['name'],
                                cat: item['unit'], // Using unit as category/label
                                qty: '${item['stock']} ${item['unit']}',
                                status: isLowStock ? 'Low Stock' : 'In Stock',
                                statusColor: isLowStock ? AppColors.error : AppColors.primary,
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToForm(), // Add Item
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStockItem({required String id, required String name, required String cat, required String qty, required String status, required Color statusColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(cat, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                ]
            ),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(qty, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ]
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _deleteItem(id),
          ),
        ],
      ),
    );
  }
}
