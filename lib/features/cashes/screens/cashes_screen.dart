import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/profile_button.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';
import 'package:gosir/shared/widgets/animated_entry.dart';

class CashesScreen extends StatefulWidget {
  const CashesScreen({super.key});

  @override
  State<CashesScreen> createState() => _CashesScreenState();
}

class _CashesScreenState extends State<CashesScreen> {
  final ApiService _api = ApiService();
  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedSortBy = 'Tanggal';
  String? _selectedSortDirection = 'Z-A / Besar-Kecil';
  String? _selectedType = 'Semua Tipe';
  String? _selectedDateRange = 'Semua Waktu';

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
      if (_selectedType != null && _selectedType != 'Semua Tipe') {
        params['type'] = _selectedType == 'Pemasukan' ? 'INCOME' : 'OUTCOME';
      }

      if (_selectedDateRange != null && _selectedDateRange != 'Semua Waktu') {
        final now = DateTime.now();
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        if (_selectedDateRange == 'Hari Ini') {
          params['date_from'] = formatter.format(now);
          params['date_to'] = formatter.format(now);
        } else if (_selectedDateRange == 'Minggu Ini') {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          params['date_from'] = formatter.format(startOfWeek);
          params['date_to'] = formatter.format(endOfWeek);
        } else if (_selectedDateRange == 'Bulan Ini') {
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);
          params['date_from'] = formatter.format(startOfMonth);
          params['date_to'] = formatter.format(endOfMonth);
        }
      }

      final res = await _api.get('/cashes', params: params.isNotEmpty ? params : null);
      if (mounted) {
        setState(() {
          List<dynamic> fetchedItems = res['data']['items'] ?? [];
          
          fetchedItems.sort((a, b) {
            int result = 0;
            if (_selectedSortBy == 'Tanggal') {
              final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
              final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
              result = dateA.compareTo(dateB);
            } else if (_selectedSortBy == 'Deskripsi') {
              final strA = (a['description'] ?? '').toString().toLowerCase();
              final strB = (b['description'] ?? '').toString().toLowerCase();
              result = strA.compareTo(strB);
            } else if (_selectedSortBy == 'Jumlah') {
              final numA = parseDouble(a['amount']);
              final numB = parseDouble(b['amount']);
              result = numA.compareTo(numB);
            }
            
            if (_selectedSortDirection == 'Z-A / Besar-Kecil') {
              return -result;
            }
            return result;
          });

          _items = fetchedItems;
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

  void _showFormModal({Map<String, dynamic>? item}) {
    final descriptionController = TextEditingController(text: item?['description'] ?? '');
    final amountController = TextEditingController(text: item?['amount']?.toString() ?? '');
    String type = item?['type'] ?? 'INCOME';
    final bool isEdit = item != null;
    String? amountErrorText;
    String? descriptionErrorText;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CashForm',
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
          titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          actionsPadding: const EdgeInsets.all(16),
          title: Text(isEdit ? 'Ubah Catatan Kas' : 'Tambah Catatan Kas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'INCOME', child: Text('Pemasukan', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: 'OUTCOME', child: Text('Pengeluaran', style: TextStyle(fontSize: 14))),
                  ],
                  onChanged: (v) => setModalState(() => type = v!),
                  decoration: _inputDecoration(''),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                ),
                const SizedBox(height: 16),
                Text('Jumlah (Rp)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration('0', errorText: amountErrorText),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    if (amountErrorText != null) setModalState(() => amountErrorText = null);
                  },
                ),
                const SizedBox(height: 16),
                Text('Keterangan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration('Contoh: Beli bahan baku', errorText: descriptionErrorText),
                  maxLines: 2,
                  onChanged: (v) {
                    if (descriptionErrorText != null) setModalState(() => descriptionErrorText = null);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontWeight: FontWeight.w600))
            ),
            ScaleOnTap(
              onTap: () async {
                bool hasError = false;
                final amountTrimmed = amountController.text.trim();
                final descriptionTrimmed = descriptionController.text.trim();
                final parsedAmount = double.tryParse(amountTrimmed);

                if (amountTrimmed.isEmpty) {
                  setModalState(() => amountErrorText = 'Jumlah wajib diisi');
                  hasError = true;
                } else if (parsedAmount == null || parsedAmount <= 0) {
                  setModalState(() => amountErrorText = 'Jumlah harus berupa angka lebih dari 0');
                  hasError = true;
                }
                if (descriptionTrimmed.isEmpty) {
                  setModalState(() => descriptionErrorText = 'Keterangan wajib diisi');
                  hasError = true;
                }
                if (hasError) return;

                try {
                  final data = {
                    'type': type,
                    'amount': parsedAmount,
                    'description': descriptionTrimmed,
                  };
                  if (isEdit) {
                    await _api.put('/cashes/${item['id']}', data);
                  } else {
                    await _api.post('/cashes', data);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                } catch (e) {
                  if (context.mounted) {
                    setModalState(() => amountErrorText = e.toString());
                  }
                }
              },
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, 
                  foregroundColor: Theme.of(context).cardColor, 
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 14),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)),
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

  Widget _buildFilterSection(bool isDesktop) {
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
                        'Cari Catatan Kas',
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
                          hintText: 'Cari deskripsi...',
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
                const SizedBox(width: 16),
                ScaleOnTap(
                  onTap: () => _showFormModal(),
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Tambah Catatan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary,
                      foregroundColor: isDark ? const Color(0xFF0A0D0B) : const Color(0xFFFFFFFF),
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )
          else
            // Search Input on Mobile
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Catatan Kas',
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
                    hintText: 'Cari deskripsi...',
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
                  child: _buildFilterDropdown<String?>(
                    label: 'Berdasarkan',
                    value: _selectedSortBy,
                    items: const [
                      DropdownMenuItem(value: 'Tanggal', child: Text('Tanggal')),
                      DropdownMenuItem(value: 'Deskripsi', child: Text('Deskripsi')),
                      DropdownMenuItem(value: 'Jumlah', child: Text('Jumlah')),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedSortBy = val);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Urutan',
                    value: _selectedSortDirection,
                    items: const [
                      DropdownMenuItem(value: 'A-Z / Kecil-Besar', child: Text('A-Z / Kecil-Besar')),
                      DropdownMenuItem(value: 'Z-A / Besar-Kecil', child: Text('Z-A / Besar-Kecil')),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedSortDirection = val);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Tipe',
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'Semua Tipe', child: Text('Semua Tipe')),
                      DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                      DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedType = val);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown<String?>(
                    label: 'Rentang Tanggal',
                    value: _selectedDateRange,
                    items: const [
                      DropdownMenuItem(value: 'Semua Waktu', child: Text('Semua Waktu')),
                      DropdownMenuItem(value: 'Hari Ini', child: Text('Hari Ini')),
                      DropdownMenuItem(value: 'Minggu Ini', child: Text('Minggu Ini')),
                      DropdownMenuItem(value: 'Bulan Ini', child: Text('Bulan Ini')),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedDateRange = val);
                      _fetchData();
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
                      child: _buildFilterDropdown<String?>(
                        label: 'Berdasarkan',
                        value: _selectedSortBy,
                        items: const [
                          DropdownMenuItem(value: 'Tanggal', child: Text('Tanggal')),
                          DropdownMenuItem(value: 'Deskripsi', child: Text('Deskripsi')),
                          DropdownMenuItem(value: 'Jumlah', child: Text('Jumlah')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedSortBy = val);
                          _fetchData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown<String?>(
                        label: 'Urutan',
                        value: _selectedSortDirection,
                        items: const [
                          DropdownMenuItem(value: 'A-Z / Kecil-Besar', child: Text('A-Z / Kecil-Besar')),
                          DropdownMenuItem(value: 'Z-A / Besar-Kecil', child: Text('Z-A / Besar-Kecil')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedSortDirection = val);
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
                        label: 'Tipe',
                        value: _selectedType,
                        items: const [
                          DropdownMenuItem(value: 'Semua Tipe', child: Text('Semua Tipe')),
                          DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                          DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedType = val);
                          _fetchData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown<String?>(
                        label: 'Rentang',
                        value: _selectedDateRange,
                        items: const [
                          DropdownMenuItem(value: 'Semua Waktu', child: Text('Semua Waktu')),
                          DropdownMenuItem(value: 'Hari Ini', child: Text('Hari Ini')),
                          DropdownMenuItem(value: 'Minggu Ini', child: Text('Minggu Ini')),
                          DropdownMenuItem(value: 'Bulan Ini', child: Text('Bulan Ini')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedDateRange = val);
                          _fetchData();
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 5)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Catatan Kas', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
              actions: [const ProfileButton()],
            ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 5),
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
                          'Catatan Kas',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola catatan pemasukan dan pengeluaran operasional.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                _buildFilterSection(isDesktop),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                      : _items.isEmpty
                          ? Center(child: Text("Belum ada catatan kas", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return AnimateEntry(
                                  delay: Duration(milliseconds: (index % 12) * 50),
                                  child: _cashCard(item),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop
          ? ScaleOnTap(
              onTap: () => _showFormModal(),
              child: FloatingActionButton(
                onPressed: null,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF10B981)
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0A0D0B)
                    : const Color(0xFFFFFFFF),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }

  Widget _cashCard(Map<String, dynamic> item) {
    final bool isIncome = item['type'] == 'INCOME';
    final amount = parseDouble(item['amount']);

    return ScaleOnTap(
      onTap: () => _showFormModal(item: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 22,
            ),
          ),
          title: Text(
            isIncome ? 'Pemasukan' : 'Pengeluaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(item['description'] ?? '-', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13)),
            ]
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}${currency.format(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          onTap: null, // Handled by ScaleOnTap wrapper
        ),
      ),
    );
  }
}
