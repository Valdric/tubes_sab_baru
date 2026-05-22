import 'package:gosir/shared/widgets/profile_button.dart';
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
          SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
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
        title: Text('Checkout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerNameController,
                decoration: InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'DINE_IN', child: Text('Dine In')),
                  DropdownMenuItem(value: 'TAKE_AWAY', child: Text('Take Away')),
                ],
                onChanged: (v) => type = v!,
                decoration: InputDecoration(labelText: 'Tipe Pesanan'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                items: const [
                  DropdownMenuItem(value: 'CASH', child: Text('Tunai')),
                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                  DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
                ],
                onChanged: (v) => paymentMethod = v!,
                decoration: InputDecoration(labelText: 'Metode Pembayaran'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
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
                    SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
                  );
                }
              }
            },
            child: Text('Proses Pesanan'),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          ),
        ),
        title: Text('Kasir'),
        actions: [
          const ProfileButton(),
          if (!isDesktop)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () => _showCartBottomSheet(),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.itemCount}',
                        style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10),
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
                  padding: EdgeInsets.all(16),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) {
                          _searchQuery = v;
                          _filterMenus();
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari menu...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      SizedBox(height: 12),
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
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
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
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outline)),
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
      padding: EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() => _activeCategoryId = val ? id : null);
          _filterMenus();
        },
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
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
                      : Icon(Icons.restaurant, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  if (isOutOfStock)
                    Container(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                      child: Center(
                        child: Text(
                          'HABIS',
                          style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu['name'] ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    currency.format(price),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
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
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.shopping_cart_outlined),
              SizedBox(width: 8),
              Text('Pesanan Saat Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Divider(height: 1),
        Expanded(
          child: cart.items.isEmpty
              ? Center(child: Text('Keranjang masih kosong.'))
              : ListView.builder(
                  itemCount: cart.itemCount,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return _cartItemTile(item);
                  },
                ),
        ),
        Divider(height: 1),
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(currency.format(cart.totalAmount),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: cart.items.isEmpty ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text('Checkout'),
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
      title: Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(currency.format(item.price)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => cart.updateQuantity(item.menuId, item.quantity - 1),
          ),
          Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.add_circle_outline, size: 20),
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
