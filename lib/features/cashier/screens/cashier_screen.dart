import 'package:gosir/shared/widgets/profile_button.dart';
import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/cashier/services/cart_provider.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';
import 'package:gosir/shared/widgets/animated_entry.dart';

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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.toString().replaceAll('Exception:', ''))),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
    String orderType = 'DINE_IN';
    String paymentMethod = 'CASH';
    bool isSubmitting = false;

    final success = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Checkout',
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
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 440,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF141414) : const Color(0xFFF4F2FC),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            border: Border(
                              bottom: BorderSide(
                                color: isDark ? const Color(0xFF2A2A2A) : AppColors.border.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.payments_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Secure Checkout',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    Text(
                                      'Total: ${currency.format(cart.totalAmount)}',
                                      style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF757684) : AppColors.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),

                        // Form Fields
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer Name
                              Text(
                                'Customer Name',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFF2EFF9) : AppColors.mutedForeground, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: customerNameController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. John Doe (General Customer)',
                                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                                  fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFEFEDF6),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Order Type Selection
                              Text(
                                'Order Type',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFF2EFF9) : AppColors.mutedForeground, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Center(child: Text('Dine In')),
                                      selected: orderType == 'DINE_IN',
                                      selectedColor: AppColors.primary,
                                      checkmarkColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color: orderType == 'DINE_IN' ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.75) : AppColors.foreground),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      onSelected: (selected) {
                                        if (selected) setDialogState(() => orderType = 'DINE_IN');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Center(child: Text('Take Away')),
                                      selected: orderType == 'TAKE_AWAY',
                                      selectedColor: AppColors.primary,
                                      checkmarkColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color: orderType == 'TAKE_AWAY' ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.75) : AppColors.foreground),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      onSelected: (selected) {
                                        if (selected) setDialogState(() => orderType = 'TAKE_AWAY');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Payment Method Selection
                              Text(
                                'Payment Method',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFF2EFF9) : AppColors.mutedForeground, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _paymentOption(
                                    label: 'Tunai',
                                    methodValue: 'CASH',
                                    icon: Icons.money_rounded,
                                    currentMethod: paymentMethod,
                                    isDark: isDark,
                                    onTap: () => setDialogState(() => paymentMethod = 'CASH'),
                                  ),
                                  const SizedBox(width: 8),
                                  _paymentOption(
                                    label: 'QRIS',
                                    methodValue: 'QRIS',
                                    icon: Icons.qr_code_scanner_rounded,
                                    currentMethod: paymentMethod,
                                    isDark: isDark,
                                    onTap: () => setDialogState(() => paymentMethod = 'QRIS'),
                                  ),
                                  const SizedBox(width: 8),
                                  _paymentOption(
                                    label: 'Transfer',
                                    methodValue: 'TRANSFER',
                                    icon: Icons.account_balance_rounded,
                                    currentMethod: paymentMethod,
                                    isDark: isDark,
                                    onTap: () => setDialogState(() => paymentMethod = 'TRANSFER'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF141414) : const Color(0xFFFFFFFF),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            border: Border(
                              top: BorderSide(
                                color: isDark ? const Color(0xFF2A2A2A) : AppColors.border.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(color: isDark ? const Color(0xFF757684) : AppColors.mutedForeground, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                                  foregroundColor: isDark ? const Color(0xFF00105C) : AppColors.onPrimary,
                                  minimumSize: const Size(160, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        setDialogState(() => isSubmitting = true);
                                        try {
                                          final orderData = {
                                            'customer_name': customerNameController.text.isEmpty ? 'Pelanggan Umum' : customerNameController.text,
                                            'type': orderType,
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
                                              SnackBar(
                                                content: Text(e.toString().replaceAll('Exception:', '')),
                                                backgroundColor: Theme.of(context).colorScheme.error,
                                              ),
                                            );
                                          }
                                        } finally {
                                          setDialogState(() => isSubmitting = false);
                                        }
                                      },
                                child: isSubmitting
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF00105C) : AppColors.onPrimary),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.check_circle_outline_rounded, size: 18),
                                          SizedBox(width: 8),
                                          Text('Process Order', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (success == true) {
      cart.clear();
      _fetchData(); // Refresh to update stocks
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Order successfully processed!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  static Widget _paymentOption({
    required String label,
    required String methodValue,
    required IconData icon,
    required String currentMethod,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = currentMethod == methodValue;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF293CA0).withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.06))
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? (isDark ? const Color(0xFFBAC3FF) : AppColors.primary)
                  : (isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.6)),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? (isDark ? const Color(0xFFBAC3FF) : AppColors.primary) : (isDark ? const Color(0xFF757684) : AppColors.mutedForeground),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? (isDark ? const Color(0xFFBAC3FF) : AppColors.primary) : (isDark ? const Color(0xFF757684) : AppColors.mutedForeground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    final cart = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF141414) : AppColors.card,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? const Color(0xFFF2EFF9) : AppColors.primary),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          ),
        ),
        title: Text(
          'Gosir',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
          ),
        ),
        actions: [
          const ProfileButton(),
          const SizedBox(width: 8),
          if (!isDesktop)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: isDark ? const Color(0xFFF2EFF9) : AppColors.mutedForeground),
                  onPressed: () => _showCartBottomSheet(),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.destructive, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(width: 16),
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
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : AppColors.card,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Modern Search
                      TextField(
                        onChanged: (v) {
                          _searchQuery = v;
                          _filterMenus();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search menus by name...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFEFEDF6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Smooth scroll categories
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _categoryChip(null, 'All Items', isDark),
                            ..._categories.map((c) => _categoryChip(c['id'].toString(), c['name'], isDark)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Grid
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : (_filteredMenus.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 48, color: AppColors.mutedForeground.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No menus matched your search query',
                                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : MediaQuery.of(context).size.width > 900 ? 4 : MediaQuery.of(context).size.width > 600 ? 3 : 2,
                                  childAspectRatio: 0.72,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _filteredMenus.length,
                              itemBuilder: (context, index) {
                                final menu = _filteredMenus[index];
                                return AnimateEntry(
                                  delay: Duration(milliseconds: 50 * (index % 12)),
                                  child: _menuItemCard(menu, isDark),
                                );
                              },
                            )),
                ),
              ],
            ),
          ),

          // Sidebar Cart (Desktop Landscape View)
          if (isDesktop)
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : AppColors.card,
                border: Border(
                  left: BorderSide(
                    color: isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: _cartContent(isDark),
            ),
        ],
      ),
      floatingActionButton: (!isDesktop && cart.itemCount > 0)
          ? FloatingActionButton.extended(
              onPressed: () => _showCartBottomSheet(),
              backgroundColor: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
              foregroundColor: isDark ? const Color(0xFF00105C) : AppColors.onPrimary,
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text(
                'Checkout (${cart.itemCount})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _categoryChip(String? id, String label, bool isDark) {
    final isSelected = _activeCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ScaleOnTap(
        onTap: () {
          setState(() => _activeCategoryId = _activeCategoryId == id ? null : id);
          _filterMenus();
        },
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) {}, // Handled by ScaleOnTap
          selectedColor: isDark ? const Color(0xFF293CA0) : AppColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : (isDark ? const Color(0xFFF2EFF9) : AppColors.mutedForeground),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.6)),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _menuItemCard(Map<String, dynamic> menu, bool isDark) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final price = parseDouble(menu['price']);
    final stock = parseDouble(menu['stock']);
    final isOutOfStock = stock <= 0;
    final isLowStock = stock > 0 && stock <= 5;

    return ScaleOnTap(
      onTap: isOutOfStock
          ? null
          : () {
              cart.addItem(
                menu['id'].toString(),
                menu['name'],
                price,
                menu['image_url'],
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${menu['name']} added to order.'),
                  duration: const Duration(milliseconds: 600),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        color: isDark ? const Color(0xFF141414) : AppColors.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  menu['image_url'] != null && menu['image_url'].toString().isNotEmpty
                      ? Image.network(
                          menu['image_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F2FC),
                            child: Icon(Icons.restaurant_rounded, size: 36, color: isDark ? const Color(0xFF757684) : AppColors.primary.withValues(alpha: 0.4)),
                          ),
                        )
                      : Container(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F2FC),
                          child: Icon(Icons.restaurant_rounded, size: 36, color: isDark ? const Color(0xFF757684) : AppColors.primary.withValues(alpha: 0.4)),
                        ),
                  // Semi-transparent overlay if Out of stock
                  if (isOutOfStock)
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: const Center(
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                        ),
                      ),
                    ),
                  // Stock badges
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? AppColors.destructive
                            : (isLowStock ? AppColors.warning : AppColors.success),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        isOutOfStock
                            ? 'HABIS'
                            : (isLowStock ? 'LOW STOCK (${stock.toInt()})' : 'READY (${stock.toInt()})'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menu Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu['name'] ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currency.format(price),
                          style: TextStyle(
                            color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!isOutOfStock)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: isDark ? const Color(0xFF00105C) : Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartContent(bool isDark) {
    final cart = Provider.of<CartProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title banner
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Current Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary),
              ),
              const Spacer(),
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () => cart.clear(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.destructive, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Cart items list
        Expanded(
          child: cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_rounded, size: 48, color: AppColors.mutedForeground.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text(
                        'Cart is empty',
                        style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cart.itemCount,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return _cartItemTile(item, isDark);
                  },
                ),
        ),
        const Divider(height: 1),

        // Calculations & Charge button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : const Color(0xFFF4F2FC),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF757684) : AppColors.mutedForeground),
                  ),
                  Text(
                    currency.format(cart.totalAmount),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFF2EFF9) : AppColors.foreground),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF2EFF9) : AppColors.foreground),
                  ),
                  Text(
                    currency.format(cart.totalAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: cart.items.isEmpty ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                  foregroundColor: isDark ? const Color(0xFF00105C) : AppColors.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.payment_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Charge Order',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cartItemTile(CartItem item, bool isDark) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2E3D) : AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  currency.format(item.price),
                  style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF757684) : AppColors.mutedForeground),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.remove_circle_outline_rounded, size: 22, color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary),
                onPressed: () => cart.updateQuantity(item.menuId, item.quantity - 1),
              ),
              const SizedBox(width: 4),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.add_circle_outline_rounded, size: 22, color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary),
                onPressed: () => cart.updateQuantity(item.menuId, item.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _cartContent(isDark),
      ),
    );
  }
}

