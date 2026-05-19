import 'package:gosir/main.dart';
import 'package:flutter/material.dart';
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/ingredients', params: _searchQuery.isNotEmpty ? {'search': _searchQuery} : null);
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
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteIngredient(int id) async {
    try {
      await _api.delete('/ingredients/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bahan berhasil dihapus'), backgroundColor: Colors.green),
        );
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFormModal({Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final stockController = TextEditingController(text: item?['stock']?.toString() ?? '0');
    final thresholdController = TextEditingController(text: item?['threshold']?.toString() ?? '10');
    String selectedUnit = item?['unit'] ?? 'GRAM';
    final bool isEdit = item != null;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Ubah Bahan Baku' : 'Tambah Bahan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Bahan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration('Misal: Kopi Arabica'),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stok', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('0'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Satuan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedUnit,
                            items: ['GRAM', 'ML', 'PCS']
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) => setModalState(() => selectedUnit = val!),
                            decoration: _inputDecoration(''),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Batas Minimal (Threshold)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(height: 8),
                TextFormField(
                  controller: thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('10'),
                ),
                if (errorText != null) ...[
                  SizedBox(height: 8),
                  Text(errorText!, style: TextStyle(color: Colors.red, fontSize: 12)),
                ]
              ],
            ),
          ),
          actions: [const ThemeToggle(), 
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                try {
                  final data = {
                    'name': nameController.text.trim(),
                    'stock': double.tryParse(stockController.text) ?? 0,
                    'unit': selectedUnit,
                    'threshold': double.tryParse(thresholdController.text) ?? 10,
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
                  setModalState(() => errorText = e.toString());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF065F46), foregroundColor: Theme.of(context).cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final bool isAdmin = _role.toUpperCase() == 'ADMIN' || _role.toUpperCase() == 'SUPERADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 3)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Bahan Baku', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stok Bahan Baku', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            SizedBox(height: 4),
                            Text('Pantau dan kelola ketersediaan bahan baku produksi Anda.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ],
                        ),
                        if (isAdmin)
                          ElevatedButton.icon(
                            onPressed: () => _showFormModal(),
                            icon: Icon(Icons.add_box_outlined),
                            label: Text('Tambah Bahan'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF065F46), foregroundColor: Theme.of(context).cardColor, minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0, vertical: 8.0),
                  child: TextField(
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      _fetchData();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari bahan baku...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Color(0xFF065F46)))
                      : _items.isEmpty
                        ? Center(child: Text("Belum ada bahan baku"))
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _ingredientTile(item, isAdmin);
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

  Widget _ingredientTile(Map<String, dynamic> item, bool isAdmin) {
    final double stock = parseDouble(item['stock']);
    final double threshold = parseDouble(item['threshold'] ?? 10);
    final bool isLowStock = stock <= threshold;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isLowStock ? Colors.red : const Color(0xFF065F46)).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            color: isLowStock ? Colors.red : const Color(0xFF065F46),
          ),
        ),
        title: Text(item['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Tersedia: $stock ${item['unit'] ?? ''}', style: TextStyle(color: isLowStock ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal)),
            if (isLowStock)
              Text('Stok hampir habis!', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showFormModal(item: item)),
                  IconButton(icon: Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _showDeleteConfirm(item)),
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
        title: Text('Hapus Bahan'),
        content: Text('Apakah Anda yakin ingin menghapus "${item['name']}"? Stok akan hilang dari sistem.'),
        actions: [const ThemeToggle(), 
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIngredient(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Theme.of(context).cardColor),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
