import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/profile_button.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/shared/widgets/animated_entry.dart';
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cari Pesanan',
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
                  hintText: 'Cari pesanan (Nama Pelanggan / ID)...',
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
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown<String?>(
                  label: isDesktop ? 'Tipe Pesanan' : 'Tipe',
                  value: _selectedType,
                  items: [
                    DropdownMenuItem(value: null, child: Text('Semua Tipe', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                    const DropdownMenuItem(value: 'DINE_IN', child: Text('Dine In')),
                    const DropdownMenuItem(value: 'TAKE_AWAY', child: Text('Take Away')),
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
                  label: 'Pembayaran',
                  value: _selectedPayment,
                  items: [
                    DropdownMenuItem(value: null, child: Text('Semua Pembayaran', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
                    const DropdownMenuItem(value: 'CASH', child: Text('Tunai')),
                    const DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                    const DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedPayment = val);
                    _fetchData();
                  },
                ),
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
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 4)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Riwayat Pesanan', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
              actions: [const ProfileButton()],
            ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 4),
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
                          'Riwayat Pesanan',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pantau dan lihat kembali transaksi yang telah dilakukan.',
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
                          ? Center(child: Text('Belum ada pesanan.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return AnimateEntry(
                                  delay: Duration(milliseconds: (index % 12) * 50),
                                  child: _orderCard(item),
                                );
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
