import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/shared/widgets/mobile_bottom_nav.dart';
import 'package:tubes_ppm_sab/features/profile/screens/profile_screen.dart';
import 'package:tubes_ppm_sab/core/services/api_service.dart';
import 'package:tubes_ppm_sab/features/inventory/screens/inventory_form_screen.dart'; // Import Form

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
      final response = await _api.get('/inventory');

      if (mounted) {
        setState(() {
          // Asumsi API return { "data": [...] } atau langsung [...]
          if (response is List) {
            _inventoryItems = response;
          } else if (response is Map && response['data'] != null) {
            _inventoryItems = response['data'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Tetap tampilkan list kosong jika error
        _inventoryItems = [];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load inventory: $e')));
      }
    }
  }

  // FUNGSI DELETE DENGAN KONFIRMASI
  Future<void> _deleteItem(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
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
      await _api.delete('/inventory/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted successfully')));
        _fetchInventory(); // Refresh data
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
                            final isLowStock = item['status'] == 'Low Stock';
                            return InkWell(
                              onTap: () => _navigateToForm(item), // Edit Item
                              child: _buildStockItem(
                                id: item['id'],
                                name: item['name'],
                                cat: item['category'],
                                qty: item['qty'].toString(),
                                status: item['status'],
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

  Widget _buildStockItem({required int id, required String name, required String cat, required String qty, required String status, required Color statusColor}) {
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