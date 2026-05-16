import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/core/utils/safe_parse.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/ingredients');
      final me = await _api.get('/auth/me');
      if (mounted) {
        setState(() {
          _items = res['data']['items'] ?? [];
          _role = me['data']['role'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.destructive),
        );
      }
    }
  }

  Future<void> _deleteIngredient(int id) async {
    try {
      await _api.delete('/ingredients/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bahan berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.destructive),
        );
      }
    }
  }

  void _showFormModal({Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final stockController = TextEditingController(text: item?['stock']?.toString() ?? '0');
    final unitController = TextEditingController(text: item?['unit'] ?? 'gr');
    final bool isEdit = item != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Ubah Bahan' : 'Tambah Bahan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Bahan'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stok'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Satuan'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                final data = {
                  'name': nameController.text,
                  'stock': stockController.text,
                  'unit': unitController.text,
                };
                if (isEdit) {
                  await _api.put('/ingredients/${item['id']}', data);
                } else {
                  await _api.post('/ingredients', data);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _fetchData();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.destructive),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final bool isAdmin = _role.toUpperCase() == 'ADMIN' || _role.toUpperCase() == 'SUPERADMIN';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 3)) : null,
      appBar: isDesktop ? null : AppBar(title: const Text('Inventaris Bahan')),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Inventaris Bahan', style: Theme.of(context).textTheme.displayMedium),
                            const Text('Kelola stok bahan baku untuk menu Anda.',
                                style: TextStyle(color: AppColors.mutedForeground)),
                          ],
                        ),
                        if (isAdmin)
                          ElevatedButton.icon(
                            onPressed: () => _showFormModal(),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Bahan'),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 45)),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: EdgeInsets.all(isDesktop ? 24 : 16),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _ingredientCard(item, isAdmin);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 3),
    );
  }

  Widget _ingredientCard(Map<String, dynamic> item, bool isAdmin) {
    final double stock = parseDouble(item['stock']);
    final bool isLowStock = stock < 10; // Threshold example

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isLowStock ? Colors.red : Colors.green).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: isLowStock ? Colors.red : Colors.green,
          ),
        ),
        title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Tersedia: $stock ${item['unit'] ?? ''}'),
        trailing: isAdmin
            ? PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') {
                    _showFormModal(item: item);
                  } else if (val == 'delete') {
                    _showDeleteConfirm(item);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: AppColors.destructive))),
                ],
              )
            : null,
      ),
    );
  }

  void _showDeleteConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bahan'),
        content: Text('Apakah Anda yakin ingin menghapus bahan "${item['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIngredient(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
