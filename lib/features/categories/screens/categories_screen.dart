import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:intl/intl.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _role = '';
  String _searchQuery = '';
  String? _sortBy;
  String? _sortDirection;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, String> params = {};
      if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;
      if (_sortBy != null) params['sort_by'] = _sortBy!;
      if (_sortDirection != null) params['sort_direction'] = _sortDirection!;

      final res = await _api.get('/categories', params: params.isNotEmpty ? params : null);
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

  Future<void> _deleteCategory(int id) async {
    try {
      await _api.delete('/categories/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus'), backgroundColor: Colors.green),
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
    final bool isEdit = item != null;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Ubah Kategori' : 'Tambah Kategori',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Kategori', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Misal: Makanan Penutup',
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                autofocus: true,
                onChanged: (val) {
                  if (errorText != null) setModalState(() => errorText = null);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  setModalState(() => errorText = 'Nama kategori wajib diisi');
                  return;
                }
                try {
                  if (isEdit) {
                    await _api.put('/categories/${item['id']}', {'name': nameController.text.trim()});
                  } else {
                    await _api.post('/categories', {'name': nameController.text.trim()});
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                } catch (e) {
                  setModalState(() => errorText = e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF065F46),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final bool isAdmin = _role.toUpperCase() == 'ADMIN' || _role.toUpperCase() == 'SUPERADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Background like web
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 1)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text('Categories', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _showFormModal(),
                  ),
              ],
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manajemen Kategori',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Kelola dan atur kategori menu Anda untuk mempermudah transaksi.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (isAdmin)
                          ElevatedButton.icon(
                            onPressed: () => _showFormModal(),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Kategori'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF065F46),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) {
                          setState(() => _searchQuery = v);
                          _fetchData();
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari kategori...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double itemWidth = (constraints.maxWidth - 12) / 2;
                          final bool useWrap = itemWidth < 180; // Wrap if columns get narrower than 180px
                          
                          if (useWrap) {
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: _buildFilterItem('Berdasarkan', _sortBy, const [
                                    DropdownMenuItem(value: null, child: Text('Pilih berdasarkan', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'name', child: Text('Nama')),
                                    DropdownMenuItem(value: 'created_at', child: Text('Waktu Dibuat')),
                                    DropdownMenuItem(value: 'updated_at', child: Text('Waktu Diperbarui')),
                                  ], (v) => setState(() => _sortBy = v)),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: _buildFilterItem('Urutan', _sortDirection, const [
                                    DropdownMenuItem(value: null, child: Text('Pilih urutan', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'asc', child: Text('A-Z / Kecil-Besar')),
                                    DropdownMenuItem(value: 'desc', child: Text('Z-A / Besar-Kecil')),
                                  ], (v) => setState(() => _sortDirection = v)),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildFilterItem('Berdasarkan', _sortBy, const [
                                    DropdownMenuItem(value: null, child: Text('Pilih berdasarkan', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'name', child: Text('Nama')),
                                    DropdownMenuItem(value: 'created_at', child: Text('Waktu Dibuat')),
                                    DropdownMenuItem(value: 'updated_at', child: Text('Waktu Diperbarui')),
                                  ], (v) => setState(() => _sortBy = v)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterItem('Urutan', _sortDirection, const [
                                    DropdownMenuItem(value: null, child: Text('Pilih urutan', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'asc', child: Text('A-Z / Kecil-Besar')),
                                    DropdownMenuItem(value: 'desc', child: Text('Z-A / Besar-Kecil')),
                                  ], (v) => setState(() => _sortDirection = v)),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF065F46)))
                      : _items.isEmpty
                        ? const Center(child: Text("Belum ada kategori"))
                        : GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 4 : 2,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _categoryCard(item, isAdmin);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 1),
    );
  }

  Widget _categoryCard(Map<String, dynamic> item, bool isAdmin) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.category_outlined, color: Color(0xFF065F46), size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  item['name'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (isAdmin)
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showFormModal(item: item);
                  } else if (val == 'delete') {
                    _showDeleteConfirm(item);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${item['name']}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String title, String? value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          items: items,
          onChanged: (v) {
            onChanged(v);
            _fetchData();
          },
        ),
      ],
    );
  }
}
