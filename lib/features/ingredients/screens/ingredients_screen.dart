import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/profile_button.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/core/utils/safe_parse.dart';
import 'package:gosir/shared/widgets/animated_entry.dart';

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
    String? nameErrorText;
    String? stockErrorText;
    String? thresholdErrorText;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'IngredientForm',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curve.value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Ubah Bahan Baku' : 'Tambah Bahan Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Bahan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration('Misal: Kopi Arabica', errorText: nameErrorText),
                  onChanged: (v) {
                    if (nameErrorText != null) setModalState(() => nameErrorText = null);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stok', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('0', errorText: stockErrorText),
                            onChanged: (v) {
                              if (stockErrorText != null) setModalState(() => stockErrorText = null);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Satuan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 8),
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
                const SizedBox(height: 16),
                const Text('Batas Minimal (Threshold)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('10', errorText: thresholdErrorText),
                  onChanged: (v) {
                    if (thresholdErrorText != null) setModalState(() => thresholdErrorText = null);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            ScaleOnTap(
              onTap: () async {
                bool hasError = false;
                final nameTrimmed = nameController.text.trim();
                final stockParsed = double.tryParse(stockController.text.trim());
                final thresholdParsed = double.tryParse(thresholdController.text.trim());

                if (nameTrimmed.isEmpty) {
                  setModalState(() => nameErrorText = 'Nama bahan wajib diisi');
                  hasError = true;
                }
                if (stockParsed == null || stockParsed < 0) {
                  setModalState(() => stockErrorText = 'Stok harus berupa angka yang valid');
                  hasError = true;
                }
                if (thresholdParsed == null || thresholdParsed < 0) {
                  setModalState(() => thresholdErrorText = 'Batas minimal harus berupa angka yang valid');
                  hasError = true;
                }
                if (hasError) return;

                try {
                  final data = {
                    'name': nameTrimmed,
                    'stock': stockParsed,
                    'unit': selectedUnit,
                    'threshold': thresholdParsed,
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
                  setModalState(() => nameErrorText = e.toString());
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Simpan',
                  style: TextStyle(
                    color: Theme.of(context).cardColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? errorText}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor = isDark ? const Color(0xFF223029) : Theme.of(context).colorScheme.outline;

    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)),
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
    final Color cardBgColor = Theme.of(context).cardColor;
    final Color borderColor = Theme.of(context).colorScheme.outlineVariant;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Add Button Row
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari bahan baku...',
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop && isAdmin) ...[
                const SizedBox(width: 16),
                ScaleOnTap(
                  onTap: () => _showFormModal(),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 20, color: Theme.of(context).cardColor),
                        const SizedBox(width: 8),
                        Text(
                          'Tambah Bahan Baku',
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Filters Row
          if (isDesktop)
            Row(
              children: [
                // Sort Segment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Urutkan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildSortSegmentedControl(),
                        const SizedBox(width: 8),
                        _buildSortDirectionToggle(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Satuan Dropdown
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
                const SizedBox(width: 16),
                // Status Stok Dropdown
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
            // Mobile sorting & dropdowns
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Urutkan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: _buildSortSegmentedControl()),
                        const SizedBox(width: 8),
                        _buildSortDirectionToggle(),
                      ],
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

  Widget _buildSortSegmentedControl() {
    Widget buildSegment(String value, String label) {
      final bool isSelected = _sortBy == value;
      return Expanded(
        child: ScaleOnTap(
          onTap: () {
            setState(() {
              _sortBy = value;
            });
            _fetchData();
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 240,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          buildSegment('name', 'Nama'),
          buildSegment('stock', 'Stok'),
          buildSegment('created_at', 'Dibuat'),
        ],
      ),
    );
  }

  Widget _buildSortDirectionToggle() {
    final bool isAsc = _sortDirection == 'asc';
    return ScaleOnTap(
      onTap: () {
        setState(() {
          _sortDirection = isAsc ? 'desc' : 'asc';
        });
        _fetchData();
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(
          isAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
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
                        : GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop 
                                  ? (MediaQuery.of(context).size.width > 1200 ? 4 : 3) 
                                  : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: isDesktop ? 1.35 : 1.45,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return AnimateEntry(
                                delay: Duration(milliseconds: (index % 12) * 50),
                                child: _ingredientCard(item, isAdmin),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (!isDesktop && isAdmin)
          ? ScaleOnTap(
              onTap: () => _showFormModal(),
              child: FloatingActionButton(
                onPressed: null, // Handled by ScaleOnTap
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 3),
    );
  }

  Widget _ingredientCard(Map<String, dynamic> item, bool isAdmin) {
    final double stock = parseDouble(item['stock']);
    final double threshold = parseDouble(item['threshold'] ?? 10);
    final bool isLowStock = stock <= threshold && stock > 0;
    final bool isOutOfStock = stock == 0;

    Color badgeBgColor;
    Color badgeTextColor;
    String statusText;
    IconData? badgeIcon;

    if (isOutOfStock) {
      badgeBgColor = Theme.of(context).colorScheme.errorContainer;
      badgeTextColor = Theme.of(context).colorScheme.onErrorContainer;
      statusText = "Habis";
      badgeIcon = Icons.cancel_outlined;
    } else if (isLowStock) {
      badgeBgColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
      statusText = "Kritis";
      badgeIcon = Icons.warning_amber_rounded;
    } else {
      badgeBgColor = const Color(0xFFE2F1E8);
      badgeTextColor = const Color(0xFF006B5E);
      statusText = "Tersedia";
      badgeIcon = Icons.check_circle_outline;
    }

    final Color cardBorderColor = isOutOfStock
        ? Theme.of(context).colorScheme.error
        : (isLowStock ? const Color(0xFFF59E0B) : Theme.of(context).colorScheme.outlineVariant);

    final double cardBorderWidth = (isOutOfStock || isLowStock) ? 2.0 : 1.0;

    return ScaleOnTap(
      onTap: isAdmin ? () => _showFormModal(item: item) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor, width: cardBorderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section: Icon and Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Icon(
                      isOutOfStock
                          ? Icons.error_outline_rounded
                          : (isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined),
                      color: isOutOfStock
                          ? Theme.of(context).colorScheme.error
                          : (isLowStock ? const Color(0xFFF59E0B) : Theme.of(context).colorScheme.primary),
                      size: 20,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, size: 10, color: badgeTextColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showFormModal(item: item);
                            } else if (value == 'delete') {
                              _showDeleteConfirm(item);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Ubah'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Middle section: Name and threshold
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['name'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Batas Minimal: ${threshold.toStringAsFixed(0)} ${item['unit'] ?? ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Divider
              Container(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 6),
              // Bottom section: Stock Count and Unit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Stok',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stock.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? Theme.of(context).colorScheme.error
                              : (isLowStock ? const Color(0xFFD97706) : Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Satuan',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (item['unit'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(Map<String, dynamic> item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeleteConfirm',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curve.value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Bahan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "${item['name']}"? Stok akan hilang dari sistem.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ScaleOnTap(
            onTap: () {
              Navigator.pop(context);
              _deleteIngredient(item['id']);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
