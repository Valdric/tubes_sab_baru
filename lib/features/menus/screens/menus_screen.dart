import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/menus/screens/menu_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';

class MenusScreen extends StatefulWidget {
  const MenusScreen({super.key});

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
  final ApiService _api = ApiService();
  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _role = '';
  String _searchQuery = '';
  String? _selectedCategory;
  List<dynamic> _categories = [];
  final Map<int, bool> _expandedItems = {};
  String? _sortBy;
  String? _sortDirection;
  String? _division;
  String? _isActive;

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
      if (_selectedCategory != null) params['category_id'] = _selectedCategory!;
      if (_sortBy != null) params['sort_by'] = _sortBy!;
      if (_sortDirection != null) params['sort_direction'] = _sortDirection!;
      if (_division != null) params['division'] = _division!;
      if (_isActive != null) params['is_active'] = _isActive!;

      final res = await _api.get('/menus', params: params.isNotEmpty ? params : null);
      final catRes = await _api.get('/categories');
      final me = await _api.get('/auth/me');
      if (mounted) {
        setState(() {
          _items = res['data']['items'] ?? [];
          _categories = catRes['data']['items'] ?? [];
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

  Future<void> _deleteMenu(int id) async {
    try {
      await _api.delete('/menus/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu berhasil dihapus'), backgroundColor: AppColors.success),
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

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final bool isAdmin = _role.toUpperCase() == 'ADMIN' || _role.toUpperCase() == 'SUPERADMIN';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 2)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Manajemen Menu'),
            ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (v) {
                            setState(() => _searchQuery = v);
                            _fetchData();
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari menu...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterItem('Berdasarkan', _sortBy, const [
                                    DropdownMenuItem(value: null, child: Text('Semua', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'name', child: Text('Nama')),
                                    DropdownMenuItem(value: 'price', child: Text('Harga')),
                                    DropdownMenuItem(value: 'created_at', child: Text('Dibuat')),
                                    DropdownMenuItem(value: 'updated_at', child: Text('Diperbarui')),
                                  ], (v) => setState(() => _sortBy = v)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterItem('Urutan', _sortDirection, const [
                                    DropdownMenuItem(value: null, child: Text('Semua', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'asc', child: Text('A-Z')),
                                    DropdownMenuItem(value: 'desc', child: Text('Z-A')),
                                  ], (v) => setState(() => _sortDirection = v)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterItem('Kategori', _selectedCategory, [
                                    const DropdownMenuItem(value: null, child: Text('Semua Kategori', style: TextStyle(color: Colors.grey))),
                                    ..._categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? '-'))),
                                  ], (v) => setState(() => _selectedCategory = v)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterItem('Divisi', _division, const [
                                    DropdownMenuItem(value: null, child: Text('Semua Divisi', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'KITCHEN', child: Text('KITCHEN')),
                                    DropdownMenuItem(value: 'BAR', child: Text('BAR')),
                                  ], (v) => setState(() => _division = v)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterItem('Status', _isActive, const [
                                    DropdownMenuItem(value: null, child: Text('Semua Status', style: TextStyle(color: Colors.grey))),
                                    DropdownMenuItem(value: 'true', child: Text('Aktif')),
                                    DropdownMenuItem(value: 'false', child: Text('Nonaktif')),
                                  ], (v) => setState(() => _isActive = v)),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
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
                              'Manajemen Menu',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const Text(
                              'Kelola ketersediaan menu, bahan baku, harga dinamis.',
                              style: TextStyle(color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                        if (isAdmin)
                          SizedBox(
                            width: 200,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MenuFormScreen()),
                              ).then((v) => v == true ? _fetchData() : null),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Menu'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 45),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (v) {
                            setState(() => _searchQuery = v);
                            _fetchData();
                          },
                          decoration: const InputDecoration(
                            hintText: 'Cari menu...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double itemWidth = (constraints.maxWidth - 48) / 5;
                            final bool useWrap = itemWidth < 145; // Wrap if columns get narrower than 145px
                            
                            if (useWrap) {
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: 170,
                                    child: _buildFilterItem('Berdasarkan', _sortBy, const [
                                      DropdownMenuItem(value: null, child: Text('Pilih berdasarkan', style: TextStyle(color: Colors.grey))),
                                      DropdownMenuItem(value: 'name', child: Text('Nama')),
                                      DropdownMenuItem(value: 'price', child: Text('Harga')),
                                      DropdownMenuItem(value: 'created_at', child: Text('Waktu Dibuat')),
                                      DropdownMenuItem(value: 'updated_at', child: Text('Waktu Diperbarui')),
                                    ], (v) => setState(() => _sortBy = v)),
                                  ),
                                  SizedBox(
                                    width: 170,
                                    child: _buildFilterItem('Urutan', _sortDirection, const [
                                      DropdownMenuItem(value: null, child: Text('Pilih urutan', style: TextStyle(color: Colors.grey))),
                                      DropdownMenuItem(value: 'asc', child: Text('A-Z / Kecil-Besar')),
                                      DropdownMenuItem(value: 'desc', child: Text('Z-A / Besar-Kecil')),
                                    ], (v) => setState(() => _sortDirection = v)),
                                  ),
                                  SizedBox(
                                    width: 170,
                                    child: _buildFilterItem('Kategori', _selectedCategory, [
                                      const DropdownMenuItem(value: null, child: Text('Semua Kategori', style: TextStyle(color: Colors.grey))),
                                      ..._categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? '-'))),
                                    ], (v) => setState(() => _selectedCategory = v)),
                                  ),
                                  SizedBox(
                                    width: 170,
                                    child: _buildFilterItem('Divisi', _division, const [
                                      DropdownMenuItem(value: null, child: Text('Semua Divisi', style: TextStyle(color: Colors.grey))),
                                      DropdownMenuItem(value: 'KITCHEN', child: Text('KITCHEN')),
                                      DropdownMenuItem(value: 'BAR', child: Text('BAR')),
                                    ], (v) => setState(() => _division = v)),
                                  ),
                                  SizedBox(
                                    width: 170,
                                    child: _buildFilterItem('Status', _isActive, const [
                                      DropdownMenuItem(value: null, child: Text('Semua Status', style: TextStyle(color: Colors.grey))),
                                      DropdownMenuItem(value: 'true', child: Text('Aktif')),
                                      DropdownMenuItem(value: 'false', child: Text('Nonaktif')),
                                    ], (v) => setState(() => _isActive = v)),
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
                                      DropdownMenuItem(value: 'price', child: Text('Harga')),
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFilterItem('Kategori', _selectedCategory, [
                                      const DropdownMenuItem(value: null, child: Text('Semua Kategori', style: TextStyle(color: Colors.grey))),
                                      ..._categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? '-'))),
                                    ], (v) => setState(() => _selectedCategory = v)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFilterItem('Divisi', _division, const [
                                      DropdownMenuItem(value: null, child: Text('Semua Divisi', style: TextStyle(color: Colors.grey))),
                                      DropdownMenuItem(value: 'KITCHEN', child: Text('KITCHEN')),
                                      DropdownMenuItem(value: 'BAR', child: Text('BAR')),
                                    ], (v) => setState(() => _division = v)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFilterItem('Status', _isActive, const [
                                      DropdownMenuItem(value: null, child: Text('Semua Status', style: TextStyle(color: Colors.grey))),
                                      DropdownMenuItem(value: 'true', child: Text('Aktif')),
                                      DropdownMenuItem(value: 'false', child: Text('Nonaktif')),
                                    ], (v) => setState(() => _isActive = v)),
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
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Expanded(
                              child: isDesktop
                                  ? _buildMenuTable(isAdmin)
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _items.length,
                                      itemBuilder: (context, index) {
                                        final item = _items[index];
                                        return _menuItemContainer(item, isAdmin, isDesktop);
                                      },
                                    ),
                            ),
                            if (isDesktop) _buildPagination(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (!isDesktop && isAdmin)
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MenuFormScreen()),
              ).then((v) => v == true ? _fetchData() : null),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 2),
    );
  }

  Widget _menuItemContainer(Map<String, dynamic> item, bool isAdmin, bool isDesktop) {
    final bool isExpanded = _expandedItems[item['id']] ?? false;

    return Column(
      children: [
        _menuCard(item, isAdmin, isDesktop),
        if (isExpanded) _ingredientsDetail(item),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _menuCard(Map<String, dynamic> item, bool isAdmin, bool isDesktop) {
    final bool isActive = item['is_active'] == true || item['is_active'] == 1;
    final String imageUrl = item['image_url'] ?? '';
    final bool isExpanded = _expandedItems[item['id']] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Image
            Container(
              width: isDesktop ? 120 : 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: Colors.grey.shade100,
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.restaurant, color: Colors.grey),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Fix vertical overflow
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['name'] ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['category']?['name'] ?? '-',
                                style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        _statusChip(isActive),
                        const SizedBox(width: 4),
                        _divisionChip(item['division'] ?? 'KITCHEN'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currency.format(parseDouble(item['price'])),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _expandedItems[item['id']] = !isExpanded;
                            });
                          },
                          icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 14),
                          label: const Text('Detail', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isAdmin)
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuFormScreen(menu: item)),
                    ).then((v) => v == true ? _fetchData() : null);
                  } else if (val == 'delete') {
                    _showDeleteConfirm(item);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Ubah')])),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, size: 18, color: AppColors.destructive), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.destructive))]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _ingredientsDetail(Map<String, dynamic> item) {
    final recipes = item['recipes'] as List? ?? [];
    final String imageUrl = item['image_url'] ?? '';
    final String createdAt = item['created_at'] != null ? DateFormat('dd MMM yyyy, jam HH.mm').format(DateTime.parse(item['created_at'])) : '-';
    final String updatedAt = item['updated_at'] != null ? DateFormat('dd MMM yyyy, jam HH.mm').format(DateTime.parse(item['updated_at'])) : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Image on Left
          Expanded(
            flex: 1,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.restaurant, size: 50, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 24),
          // Details on Right
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Dibuat', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                          Text(createdAt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Diperbarui', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                          Text(updatedAt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade50),
                        children: const [
                          Padding(padding: EdgeInsets.all(12), child: Text('Bahan Baku', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(12), child: Text('Kuantitas yang Dibutuhkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(12), child: Text('Satuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      if (recipes.isEmpty)
                        const TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(12), child: Text('Tidak ada bahan baku', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11))),
                            SizedBox(),
                            SizedBox(),
                          ],
                        ),
                      ...recipes.map((r) => TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(12), child: Text(r['ingredient']?['name'] ?? '-', style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(12), child: Text(r['quantity']?.toString() ?? '0', style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(12), child: Text(r['ingredient']?['unit']?.toString().toLowerCase() ?? '-', style: const TextStyle(fontSize: 12))),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divisionChip(String division) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: division == 'BAR' ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        division,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: division == 'BAR' ? Colors.orange : Colors.blue,
        ),
      ),
    );
  }

  Widget _statusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Non-aktif',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  void _showDeleteConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Apakah Anda yakin ingin menghapus menu "${item['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMenu(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
  Widget _buildMenuTable(bool isAdmin) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300),
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            columnSpacing: 24,
            columns: [
              const DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('Nama Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('Harga Jual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('HPP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('Divisi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ],
            rows: _items.expand((item) {
              final index = _items.indexOf(item);
              final bool isActive = item['is_active'] == true || item['is_active'] == 1;
              final bool isExpanded = _expandedItems[item['id']] ?? false;

              return [
                DataRow(
                  cells: [
                    DataCell(Text('${index + 1}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item['image_url'] != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(item['image_url'], width: 45, height: 35, fit: BoxFit.cover),
                              ),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(item['category']?['name'] ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(currency.format(parseDouble(item['price'])), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(currency.format(parseDouble(item['hpp'] ?? 0)), style: const TextStyle(fontSize: 12))),
                    DataCell(Text('${item['stock'] ?? 0}', style: const TextStyle(fontSize: 12))),
                    DataCell(_statusChip(isActive)),
                    DataCell(_divisionChip(item['division'] ?? 'KITCHEN')),
                    DataCell(
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.mutedForeground),
                        onSelected: (val) {
                          if (val == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MenuFormScreen(menu: item)),
                            ).then((v) => v == true ? _fetchData() : null);
                          } else if (val == 'detail') {
                            setState(() {
                              _expandedItems[item['id']] = !isExpanded;
                            });
                          } else if (val == 'delete') {
                            _showDeleteConfirm(item);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit', style: TextStyle(fontSize: 13))])),
                          PopupMenuItem(
                            value: 'detail',
                            child: Row(children: [Icon(isExpanded ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text(isExpanded ? 'Sembunyikan Detail' : 'Tampilkan Detail', style: const TextStyle(fontSize: 13))]),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.destructive), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.destructive, fontSize: 13))]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isExpanded)
                  DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: MediaQuery.of(context).size.width - 350,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _ingredientsDetail(item),
                        ),
                      ),
                      const DataCell(SizedBox()),
                      const DataCell(SizedBox()), // Dummy cells
                      const DataCell(SizedBox()),
                      const DataCell(SizedBox()),
                      const DataCell(SizedBox()),
                      const DataCell(SizedBox()),
                      const DataCell(SizedBox()),
                    ].take(8).toList(),
                  ),
              ];
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Hal. 1 dari 1', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: 10,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    items: [10, 20, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e / Hal'))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: null, icon: const Icon(Icons.chevron_left)),
              IconButton(onPressed: null, icon: const Icon(Icons.chevron_right)),
            ],
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
