import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
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
  String? _selectedType;

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
      if (_selectedType != null) params['type'] = _selectedType!;

      final res = await _api.get('/cashes', params: params.isNotEmpty ? params : null);
      if (mounted) {
        setState(() {
          _items = res['data']['items'] ?? [];
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

  void _showFormModal({Map<String, dynamic>? item}) {
    final descriptionController = TextEditingController(text: item?['description'] ?? '');
    final amountController = TextEditingController(text: item?['amount']?.toString() ?? '');
    String type = item?['type'] ?? 'INCOME';
    final bool isEdit = item != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(isEdit ? 'Ubah Catatan Kas' : 'Tambah Catatan Kas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'INCOME', child: Text('Pemasukan')),
                  DropdownMenuItem(value: 'OUTCOME', child: Text('Pengeluaran')),
                ],
                onChanged: (v) => setModalState(() => type = v!),
                decoration: const InputDecoration(labelText: 'Tipe'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
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
                      SnackBar(content: Text(e.toString()), backgroundColor: AppColors.destructive),
                    );
                  }
                }
              },
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

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 5)) : null,
      appBar: isDesktop ? null : AppBar(title: const Text('Catatan Kas')),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 5),
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
                            Text('Catatan Kas', style: Theme.of(context).textTheme.displayMedium),
                            const Text('Kelola catatan pemasukan dan pengeluaran operasional.',
                                style: TextStyle(color: AppColors.mutedForeground)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showFormModal(),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Catatan'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 45)),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          onChanged: (v) {
                            setState(() => _searchQuery = v);
                            _fetchData();
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari catatan...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            hintText: 'Semua Tipe',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Semua Tipe')),
                            DropdownMenuItem(value: 'INCOME', child: Text('Pemasukan')),
                            DropdownMenuItem(value: 'OUTCOME', child: Text('Pengeluaran')),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedType = v);
                            _fetchData();
                          },
                        ),
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
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }

  Widget _cashCard(Map<String, dynamic> item) {
    final bool isIncome = item['type'] == 'INCOME';
    final amount = parseDouble(item['amount']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
        title: Text(
          isIncome ? 'Pemasukan' : 'Pengeluaran',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item['description'] ?? '-'),
        trailing: Text(
          '${isIncome ? '+' : '-'}${currency.format(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        onTap: () => _showFormModal(item: item),
      ),
    );
  }
}
