import 'package:gosir/main.dart';
import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';

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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          actionsPadding: EdgeInsets.all(16),
          title: Text(isEdit ? 'Ubah Catatan Kas' : 'Tambah Catatan Kas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'INCOME', child: Text('Pemasukan', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: 'OUTCOME', child: Text('Pengeluaran', style: TextStyle(fontSize: 14))),
                  ],
                  onChanged: (v) => setModalState(() => type = v!),
                  decoration: _inputDecoration(''),
                  icon: Icon(Icons.keyboard_arrow_down, size: 20),
                ),
                SizedBox(height: 16),
                Text('Jumlah (Rp)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
                SizedBox(height: 8),
                TextFormField(
                  controller: amountController,
                  style: TextStyle(fontSize: 14),
                  decoration: _inputDecoration('0'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                Text('Keterangan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
                SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  style: TextStyle(fontSize: 14),
                  decoration: _inputDecoration('Contoh: Beli bahan baku'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [const ThemeToggle(), 
            TextButton(
              onPressed: () => Navigator.pop(context), 
              style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontWeight: FontWeight.w600))
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isEmpty) return;
                try {
                  final data = {
                    'type': type,
                    'amount': parseDouble(amountController.text),
                    'description': descriptionController.text,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF065F46), 
                foregroundColor: Theme.of(context).cardColor, 
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 14),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFF065F46))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 5)) : null,
      appBar: isDesktop ? null : AppBar(title: const Text('Catatan Kas'), actions: const [ThemeToggle()]),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catatan Kas', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        SizedBox(height: 4),
                        Text('Kelola catatan pemasukan dan pengeluaran operasional.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cari Catatan Kas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) {
                                setState(() => _searchQuery = v);
                                _fetchData();
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Cari deskripsi...',
                                hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                                prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFF065F46))),
                              ),
                            ),
                          ),
                          if (isDesktop) ...[
                            SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => _showFormModal(),
                              icon: Icon(Icons.add, size: 18),
                              label: Text('Tambah Catatan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF065F46), 
                                foregroundColor: Theme.of(context).cardColor, 
                                elevation: 0,
                                minimumSize: const Size(0, 46),
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              ),
                            ),
                          ]
                        ],
                      ),
                      SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmall = constraints.maxWidth < 600;
                          if (isSmall) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildDropdown('Berdasarkan', ['Tanggal', 'Deskripsi', 'Jumlah'], _selectedSortBy ?? 'Tanggal', (v) { setState(() { _selectedSortBy = v; _fetchData(); }); })),
                                    SizedBox(width: 12),
                                    Expanded(child: _buildDropdown('Urutan', ['A-Z / Kecil-Besar', 'Z-A / Besar-Kecil'], _selectedSortDirection ?? 'Z-A / Besar-Kecil', (v) { setState(() { _selectedSortDirection = v; _fetchData(); }); })),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _buildDropdown('Tipe', ['Semua Tipe', 'Pemasukan', 'Pengeluaran'], _selectedType ?? 'Semua Tipe', (v) { setState(() { _selectedType = v; _fetchData(); }); })),
                                    SizedBox(width: 12),
                                    Expanded(child: _buildDropdown('Rentang Tanggal', ['Semua Waktu', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'], _selectedDateRange ?? 'Semua Waktu', (v) { setState(() { _selectedDateRange = v; _fetchData(); }); })),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(child: _buildDropdown('Berdasarkan', ['Tanggal', 'Deskripsi', 'Jumlah'], _selectedSortBy ?? 'Tanggal', (v) { setState(() { _selectedSortBy = v; _fetchData(); }); })),
                                SizedBox(width: 16),
                                Expanded(child: _buildDropdown('Urutan', ['A-Z / Kecil-Besar', 'Z-A / Besar-Kecil'], _selectedSortDirection ?? 'Z-A / Besar-Kecil', (v) { setState(() { _selectedSortDirection = v; _fetchData(); }); })),
                                SizedBox(width: 16),
                                Expanded(child: _buildDropdown('Tipe', ['Semua Tipe', 'Pemasukan', 'Pengeluaran'], _selectedType ?? 'Semua Tipe', (v) { setState(() { _selectedType = v; _fetchData(); }); })),
                                SizedBox(width: 16),
                                Expanded(child: _buildDropdown('Rentang Tanggal', ['Semua Waktu', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'], _selectedDateRange ?? 'Semua Waktu', (v) { setState(() { _selectedDateRange = v; _fetchData(); }); })),
                              ],
                            );
                          }
                        }
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Color(0xFF065F46)))
                      : _items.isEmpty
                        ? Center(child: Text("Belum ada catatan kas"))
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _cashCard(item);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: () => _showFormModal(),
              backgroundColor: const Color(0xFF065F46),
              child: Icon(Icons.add, color: Theme.of(context).cardColor),
            )
          : null,
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }

  Widget _cashCard(Map<String, dynamic> item) {
    final bool isIncome = item['type'] == 'INCOME';
    final amount = parseDouble(item['amount']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
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
            SizedBox(height: 4),
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
        onTap: () => _showFormModal(item: item),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFF065F46))),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45), size: 20),
        ),
      ],
    );
  }
}
