import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/cashier/services/cart_provider.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final ApiService _api = ApiService();
  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  List<dynamic> _categories = [];
  List<dynamic> _menus = [];
  List<dynamic> _filteredMenus = [];
  String? _activeCategoryId;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final catRes = await _api.get('/cashier/categories');
      final menuRes = await _api.get('/cashier/menus');
      if (mounted) {
        setState(() {
          _categories = catRes['data'] ?? [];
          _menus = menuRes['data'] ?? [];
          _filteredMenus = _menus;
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

  void _filterMenus() {
    setState(() {
      _filteredMenus = _menus.where((m) {
        final matchesCategory = _activeCategoryId == null || m['category_id'].toString() == _activeCategoryId;
        final matchesSearch = m['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  Future<void> _handleCheckout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) return;

    final customerNameController = TextEditingController();
    String type = 'DINE_IN';
    String paymentMethod = 'CASH';

    final success = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'DINE_IN', child: Text('Dine In')),
                  DropdownMenuItem(value: 'TAKE_AWAY', child: Text('Take Away')),
                ],
                onChanged: (v) => type = v!,
                decoration: const InputDecoration(labelText: 'Tipe Pesanan'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                items: const [
                  DropdownMenuItem(value: 'CASH', child: Text('Tunai')),
                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                  DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
                ],
                onChanged: (v) => paymentMethod = v!,
                decoration: const InputDecoration(labelText: 'Metode Pembayaran'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              try {
                final orderData = {
                  'customer_name': customerNameController.text.isEmpty ? 'Pelanggan Umum' : customerNameController.text,
                  'type': type,
                  'payment_method': paymentMethod,
                  'items': cart.items.values
                      .map((i) => {
                            'menu_id': i.menuId,
                            'quantity': i.quantity,
                          })
                      .toList(),
                };
                await _api.post('/orders', orderData);
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.destructive),
                  );
                }
              }
            },
            child: const Text('Proses Pesanan'),
          ),
        ],
      ),
    );

    if (success == true) {
      cart.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: AppColors.success),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          ),
        ),
        title: const Text('Kasir'),
        actions: [
          if (!isDesktop)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => _showCartBottomSheet(),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: Row(
        children: [
          // Menu Area
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Category Filter & Search
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) {
                          _searchQuery = v;
                          _filterMenus();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari menu...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _categoryChip(null, 'Semua'),
                            ..._categories.map((c) => _categoryChip(c['id'].toString(), c['name'])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu Grid
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 4 : 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredMenus.length,
                          itemBuilder: (context, index) {
                            final menu = _filteredMenus[index];
                            return _menuItemCard(menu);
                          },
                        ),
                ),
              ],
            ),
          ),
          // Sidebar Cart (Desktop)
          if (isDesktop)
            Container(
              width: 350,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              child: _cartContent(),
            ),
        ],
      ),
    );
  }

  Widget _categoryChip(String? id, String label) {
    final isSelected = _activeCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() => _activeCategoryId = val ? id : null);
          _filterMenus();
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.foreground,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _menuItemCard(Map<String, dynamic> menu) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final price = parseDouble(menu['price']);
    final stock = parseDouble(menu['stock']);
    final isOutOfStock = stock <= 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () => cart.addItem(
                  menu['id'].toString(),
                  menu['name'],
                  price,
                  menu['image_url'],
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  menu['image_url'] != null
                      ? Image.network(menu['image_url'], fit: BoxFit.cover)
                      : const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                  if (isOutOfStock)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          'HABIS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu['name'] ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.format(price),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartContent() {
    final cart = Provider.of<CartProvider>(context);
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.shopping_cart_outlined),
              SizedBox(width: 8),
              Text('Pesanan Saat Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: cart.items.isEmpty
              ? const Center(child: Text('Keranjang masih kosong.'))
              : ListView.builder(
                  itemCount: cart.itemCount,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return _cartItemTile(item);
                  },
                ),
        ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(currency.format(cart.totalAmount),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: cart.items.isEmpty ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cartItemTile(CartItem item) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    return ListTile(
      title: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(currency.format(item.price)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => cart.updateQuantity(item.menuId, item.quantity - 1),
          ),
          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => cart.updateQuantity(item.menuId, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _cartContent(),
      ),
    );
  }
}
