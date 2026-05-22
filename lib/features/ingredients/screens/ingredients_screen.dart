import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/profile_button.dart';
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
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';
  String _selectedUnit = 'Semua Satuan';
  String _selectedStockStatus = 'Semua Stok';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, String> params = {};
      if (_searchQuery.isNotEmpty) {
        params['search'] = _searchQuery;
      }
      params['sort_by'] = _sortBy;
      params['sort_direction'] = _sortDirection;

      final res = await _api.get('/ingredients', params: params);
      final me = await _api.get('/auth/me');
      if (mounted) {
        setState(() {
          List<dynamic> items = res['data']['items'] ?? [];

          // Client-side filtering by Unit
          if (_selectedUnit != 'Semua Satuan') {
            items = items.where((item) {
              final String unit = (item['unit'] ?? '').toString().toUpperCase();
              return unit == _selectedUnit.toUpperCase();
            }).toList();
          }

          // Client-side filtering by Stock Status
          if (_selectedStockStatus != 'Semua Stok') {
            items = items.where((item) {
              final double stock = parseDouble(item['stock']);
              final double threshold = parseDouble(item['threshold'] ?? 10);
              if (_selectedStockStatus == 'Hampir Habis') {
                return stock <= threshold && stock > 0;
              } else if (_selectedStockStatus == 'Habis') {
                return stock == 0;
              }
              return true;
            }).toList();
          }

          _items = items;
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
          actions: [
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
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor = isDark ? const Color(0xFF223029) : Theme.of(context).colorScheme.outline;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color dropdownBgColor = isDark ? const Color(0xFF131A16) : const Color(0xFFFFFFFF);
    final Color borderColor = isDark ? const Color(0xFF223029) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: dropdownBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: dropdownBgColor,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary,
              ),
              isExpanded: true,
              style: TextStyle(
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(bool isDesktop, bool isAdmin) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBgColor = isDark ? const Color(0xFF131A16) : const Color(0xFFFFFFFF);
    final Color borderColor = isDark ? const Color(0xFF223029) : const Color(0xFFE2E8F0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Search Input (and Add Button on Desktop)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cari Bahan Baku',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (v) {
                          setState(() => _searchQuery = v);
                          _fetchData();
                        },
                        style: TextStyle(
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari bahan baku...',
                          prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0A0D0B) : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showFormModal(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Tambah Bahan Baku'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary,
                      foregroundColor: isDark ? const Color(0xFF0A0D0B) : const Color(0xFFFFFFFF),
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ],
            )
          else
            // Search Input on Mobile
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Bahan Baku',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  onChanged: (v) {
                    setState(() => _searchQuery = v);
                    _fetchData();
                  },
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari bahan baku...',
                    prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0A0D0B) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Row 2: The 4 Dropdowns
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown<String>(
                    label: 'Berdasarkan',
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'created_at', child: Text('Pilih berdasarkan')),
                      DropdownMenuItem(value: 'name', child: Text('Nama Bahan')),
                      DropdownMenuItem(value: 'stock', child: Text('Jumlah Stok')),
                      DropdownMenuItem(value: 'unit', child: Text('Satuan')),
                      DropdownMenuItem(value: 'updated_at', child: Text('Tanggal Diperbarui')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _sortBy = val);
                        _fetchData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String>(
                    label: 'Urutan',
                    value: _sortDirection,
                    items: const [
                      DropdownMenuItem(value: 'desc', child: Text('Pilih urutan')),
                      DropdownMenuItem(value: 'asc', child: Text('Menaik')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _sortDirection = val);
                        _fetchData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String>(
                    label: 'Satuan',
                    value: _selectedUnit,
                    items: const [
                      DropdownMenuItem(value: 'Semua Satuan', child: Text('Semua Satuan')),
                      DropdownMenuItem(value: 'GRAM', child: Text('GRAM')),
                      DropdownMenuItem(value: 'ML', child: Text('ML')),
                      DropdownMenuItem(value: 'PCS', child: Text('PCS')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedUnit = val);
                        _fetchData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String>(
                    label: 'Status Stok',
                    value: _selectedStockStatus,
                    items: const [
                      DropdownMenuItem(value: 'Semua Stok', child: Text('Semua Stok')),
                      DropdownMenuItem(value: 'Hampir Habis', child: Text('Hampir Habis')),
                      DropdownMenuItem(value: 'Habis', child: Text('Stok Habis')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedStockStatus = val);
                        _fetchData();
                      }
                    },
                  ),
                ),
              ],
            )
          else
            // Dropdowns on Mobile: 2x2 Grid using rows
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<String>(
                        label: 'Berdasarkan',
                        value: _sortBy,
                        items: const [
                          DropdownMenuItem(value: 'created_at', child: Text('Pilih berdasarkan')),
                          DropdownMenuItem(value: 'name', child: Text('Nama Bahan')),
                          DropdownMenuItem(value: 'stock', child: Text('Jumlah Stok')),
                          DropdownMenuItem(value: 'unit', child: Text('Satuan')),
                          DropdownMenuItem(value: 'updated_at', child: Text('Tanggal Diperbarui')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _sortBy = val);
                            _fetchData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown<String>(
                        label: 'Urutan',
                        value: _sortDirection,
                        items: const [
                          DropdownMenuItem(value: 'desc', child: Text('Pilih urutan')),
                          DropdownMenuItem(value: 'asc', child: Text('Menaik')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _sortDirection = val);
                            _fetchData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<String>(
                        label: 'Satuan',
                        value: _selectedUnit,
                        items: const [
                          DropdownMenuItem(value: 'Semua Satuan', child: Text('Semua Satuan')),
                          DropdownMenuItem(value: 'GRAM', child: Text('GRAM')),
                          DropdownMenuItem(value: 'ML', child: Text('ML')),
                          DropdownMenuItem(value: 'PCS', child: Text('PCS')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedUnit = val);
                            _fetchData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown<String>(
                        label: 'Status Stok',
                        value: _selectedStockStatus,
                        items: const [
                          DropdownMenuItem(value: 'Semua Stok', child: Text('Semua Stok')),
                          DropdownMenuItem(value: 'Hampir Habis', child: Text('Hampir Habis')),
                          DropdownMenuItem(value: 'Habis', child: Text('Stok Habis')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStockStatus = val);
                            _fetchData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 3)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Bahan Baku', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
              actions: [const ProfileButton()],
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
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stok Bahan Baku',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pantau dan kelola ketersediaan bahan baku produksi Anda.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                _buildFilterSection(isDesktop, isAdmin),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                      : _items.isEmpty
                        ? const Center(child: Text("Belum ada bahan baku"))
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
      floatingActionButton: (!isDesktop && isAdmin)
          ? FloatingActionButton(
              onPressed: () => _showFormModal(),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF10B981)
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0A0D0B)
                  : const Color(0xFFFFFFFF),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
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
            color: (isLowStock ? Colors.red : Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            color: isLowStock ? Colors.red : Theme.of(context).colorScheme.primary,
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
        actions: [
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
