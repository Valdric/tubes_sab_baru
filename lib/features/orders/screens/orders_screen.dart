import 'package:gosir/main.dart';
import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ApiService _api = ApiService();
  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedPayment;

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
      if (_selectedPayment != null) params['payment_method'] = _selectedPayment!;

      final res = await _api.get('/orders', params: params.isNotEmpty ? params : null);
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
          SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 4)) : null,
      appBar: isDesktop
          ? null
          : AppBar(title: const Text('Riwayat Pesanan'), actions: const [ThemeToggle()]),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Pesanan',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          'Pantau dan lihat kembali transaksi yang telah dilakukan.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0, vertical: 8.0),
                  child: TextField(
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      _fetchData();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari pesanan (Nama Pelanggan / ID)...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0, vertical: 8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double itemWidth = (constraints.maxWidth - 8) / 2;
                      final bool useWrap = itemWidth < 160;
                      
                      if (useWrap) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedType,
                                decoration: InputDecoration(
                                  hintText: 'Semua Tipe',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor,
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Semua Tipe')),
                                  DropdownMenuItem(value: 'DINE_IN', child: Text('Dine In')),
                                  DropdownMenuItem(value: 'TAKE_AWAY', child: Text('Take Away')),
                                ],
                                onChanged: (v) {
                                  setState(() => _selectedType = v);
                                  _fetchData();
                                },
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedPayment,
                                decoration: InputDecoration(
                                  hintText: 'Pembayaran',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor,
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Semua Pembayaran')),
                                  DropdownMenuItem(value: 'CASH', child: Text('Tunai')),
                                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                                  DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
                                ],
                                onChanged: (v) {
                                  setState(() => _selectedPayment = v);
                                  _fetchData();
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedType,
                                decoration: InputDecoration(
                                  hintText: 'Semua Tipe',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor,
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Semua Tipe')),
                                  DropdownMenuItem(value: 'DINE_IN', child: Text('Dine In')),
                                  DropdownMenuItem(value: 'TAKE_AWAY', child: Text('Take Away')),
                                ],
                                onChanged: (v) {
                                  setState(() => _selectedType = v);
                                  _fetchData();
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedPayment,
                                decoration: InputDecoration(
                                  hintText: 'Pembayaran',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor,
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Semua Pembayaran')),
                                  DropdownMenuItem(value: 'CASH', child: Text('Tunai')),
                                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                                  DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
                                ],
                                onChanged: (v) {
                                  setState(() => _selectedPayment = v);
                                  _fetchData();
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                          ? Center(child: Text('Belum ada pesanan.'))
                          : ListView.builder(
                              padding: EdgeInsets.all(isDesktop ? 24 : 16),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return _orderCard(item);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 4),
    );
  }

  Widget _orderCard(Map<String, dynamic> item) {
    final dateStr = item['created_at'];
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    final totalPrice = parseDouble(item['total_price']);
    final orderItems = item['order_items'] as List? ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item['customer_name'] ?? 'Pelanggan Umum',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              currency.format(totalPrice),
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                dateFormat.format(date),
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              SizedBox(width: 8),
              _typeChip(item['type'] ?? 'DINE_IN'),
            ],
          ),
        ),
        children: [
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pesanan:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                ...orderItems.map((oi) => Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${oi['quantity']}x ${oi['menu']?['name'] ?? 'Menu'}'),
                          Text(currency.format(parseDouble(oi['price']))),
                        ],
                      ),
                    )),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Metode Pembayaran', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    Text(item['payment_method'] ?? 'CASH', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kasir', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    Text(item['user']?['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}
