import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/profile_button.dart';
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
          SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
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
          SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final bool isAdmin = _role.toUpperCase() == 'ADMIN' || _role.toUpperCase() == 'SUPERADMIN';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 2)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Manajemen Menu', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
              actions: [const ProfileButton()],
            ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 2),
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
                          'Manajemen Menu',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola ketersediaan menu, bahan baku, dan harga dinamis.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                _buildFilterSection(isDesktop, isAdmin),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
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
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 2),
    );
  }

  Widget _menuItemContainer(Map<String, dynamic> item, bool isAdmin, bool isDesktop) {
    final bool isExpanded = _expandedItems[item['id']] ?? false;

    return Column(
      children: [
        _menuCard(item, isAdmin, isDesktop),
        if (isExpanded) _ingredientsDetail(item),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _menuCard(Map<String, dynamic> item, bool isAdmin, bool isDesktop) {
    final bool isActive = item['is_active'] == true || item['is_active'] == 1;
    final String imageUrl = item['image_url'] ?? '';
    final bool isExpanded = _expandedItems[item['id']] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Image
            Container(
              width: isDesktop ? 120 : 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : Icon(Icons.restaurant, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.0),
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
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['category']?['name'] ?? '-',
                                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4),
                        _statusChip(isActive),
                        SizedBox(width: 4),
                        _divisionChip(item['division'] ?? 'KITCHEN'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currency.format(parseDouble(item['price'])),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _expandedItems[item['id']] = !isExpanded;
                            });
                          },
                          icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 14),
                          label: Text('Detail', style: TextStyle(fontSize: 11)),
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
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, size: 18, color: Theme.of(context).colorScheme.error), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Theme.of(context).colorScheme.error))]),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
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
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : Icon(Icons.restaurant, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          SizedBox(width: 24),
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
                          Text('Tanggal Dibuat', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                          Text(createdAt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Diperbarui', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                          Text(updatedAt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLowest),
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
                              Padding(padding: EdgeInsets.all(12), child: Text(r['ingredient']?['name'] ?? '-', style: TextStyle(fontSize: 12))),
                              Padding(padding: EdgeInsets.all(12), child: Text(r['quantity']?.toString() ?? '0', style: TextStyle(fontSize: 12))),
                              Padding(padding: EdgeInsets.all(12), child: Text(r['ingredient']?['unit']?.toString().toLowerCase() ?? '-', style: TextStyle(fontSize: 12))),
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        title: Text('Hapus Menu'),
        content: Text('Apakah Anda yakin ingin menghapus menu "${item['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMenu(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text('Hapus'),
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
        padding: EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerLowest),
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
                    DataCell(Text('${index + 1}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item['image_url'] != null)
                            Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(item['image_url'], width: 45, height: 35, fit: BoxFit.cover),
                              ),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(item['category']?['name'] ?? '-', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(currency.format(parseDouble(item['price'])), style: TextStyle(fontSize: 12))),
                    DataCell(Text(currency.format(parseDouble(item['hpp'] ?? 0)), style: TextStyle(fontSize: 12))),
                    DataCell(Text('${item['stock'] ?? 0}', style: TextStyle(fontSize: 12))),
                    DataCell(_statusChip(isActive)),
                    DataCell(_divisionChip(item['division'] ?? 'KITCHEN')),
                    DataCell(
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                            child: Row(children: [Icon(isExpanded ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text(isExpanded ? 'Sembunyikan Detail' : 'Tampilkan Detail', style: TextStyle(fontSize: 13))]),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13))]),
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
                          padding: EdgeInsets.symmetric(vertical: 8),
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
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Hal. 1 dari 1', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: 10,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                    items: [10, 20, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e / Hal'))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: null, icon: Icon(Icons.chevron_left)),
              IconButton(onPressed: null, icon: Icon(Icons.chevron_right)),
            ],
          ),
        ],
      ),
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
                        'Cari Menu',
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
                          hintText: 'Cari menu...',
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuFormScreen()),
                    ).then((v) => v == true ? _fetchData() : null),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Tambah Menu'),
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
                  'Cari Menu',
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
                    hintText: 'Cari menu...',
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

          // Row 2: The 5 Dropdowns
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Berdasarkan',
                    value: _sortBy,
                    items: [
                      DropdownMenuItem(value: null, child: Text('Pilih berdasarkan', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                      const DropdownMenuItem(value: 'name', child: Text('Nama')),
                      const DropdownMenuItem(value: 'price', child: Text('Harga')),
                      const DropdownMenuItem(value: 'created_at', child: Text('Waktu Dibuat')),
                      const DropdownMenuItem(value: 'updated_at', child: Text('Waktu Diperbarui')),
                    ],
                    onChanged: (val) {
                      setState(() => _sortBy = val);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Urutan',
                    value: _sortDirection,
                    items: [
                      DropdownMenuItem(value: null, child: Text('Pilih urutan', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                      const DropdownMenuItem(value: 'asc', child: Text('A-Z')),
                      const DropdownMenuItem(value: 'desc', child: Text('Z-A')),
                    ],
                    onChanged: (val) {
                      setState(() => _sortDirection = val);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Kategori',
                    value: _selectedCategory,
                    items: [
                      DropdownMenuItem(value: null, child: Text('Semua Kategori', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                      ..._categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? '-'))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Divisi',
                    value: _division,
                    items: [
                      DropdownMenuItem(value: null, child: Text('Semua Divisi', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                      const DropdownMenuItem(value: 'KITCHEN', child: Text('KITCHEN')),
                      const DropdownMenuItem(value: 'BAR', child: Text('BAR')),
                    ],
                    onChanged: (val) {
                      setState(() => _division = val);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Status',
                    value: _isActive,
                    items: [
                      DropdownMenuItem(value: null, child: Text('Semua Status', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                      const DropdownMenuItem(value: 'true', child: Text('Aktif')),
                      const DropdownMenuItem(value: 'false', child: Text('Nonaktif')),
                    ],
                    onChanged: (val) {
                      setState(() => _isActive = val);
                      _fetchData();
                    },
                  ),
                ),
              ],
            )
          else
            // Dropdowns on Mobile: Grid 2x2 and 1 row for the last one
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<String?>(
                        label: 'Berdasarkan',
                        value: _sortBy,
                        items: [
                          DropdownMenuItem(value: null, child: Text('Pilih berdasarkan', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                          const DropdownMenuItem(value: 'name', child: Text('Nama')),
                          const DropdownMenuItem(value: 'price', child: Text('Harga')),
                          const DropdownMenuItem(value: 'created_at', child: Text('Waktu Dibuat')),
                          const DropdownMenuItem(value: 'updated_at', child: Text('Waktu Diperbarui')),
                        ],
                        onChanged: (val) {
                          setState(() => _sortBy = val);
                          _fetchData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown<String?>(
                        label: 'Urutan',
                        value: _sortDirection,
                        items: [
                          DropdownMenuItem(value: null, child: Text('Pilih urutan', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                          const DropdownMenuItem(value: 'asc', child: Text('A-Z')),
                          const DropdownMenuItem(value: 'desc', child: Text('Z-A')),
                        ],
                        onChanged: (val) {
                          setState(() => _sortDirection = val);
                          _fetchData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<String?>(
                        label: 'Kategori',
                        value: _selectedCategory,
                        items: [
                          DropdownMenuItem(value: null, child: Text('Semua Kategori', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                          ..._categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? '-'))),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedCategory = val);
                          _fetchData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown<String?>(
                        label: 'Divisi',
                        value: _division,
                        items: [
                          DropdownMenuItem(value: null, child: Text('Semua Divisi', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                          const DropdownMenuItem(value: 'KITCHEN', child: Text('KITCHEN')),
                          const DropdownMenuItem(value: 'BAR', child: Text('BAR')),
                        ],
                        onChanged: (val) {
                          setState(() => _division = val);
                          _fetchData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<String?>(
                        label: 'Status',
                        value: _isActive,
                        items: [
                          DropdownMenuItem(value: null, child: Text('Semua Status', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                          const DropdownMenuItem(value: 'true', child: Text('Aktif')),
                          const DropdownMenuItem(value: 'false', child: Text('Nonaktif')),
                        ],
                        onChanged: (val) {
                          setState(() => _isActive = val);
                          _fetchData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
