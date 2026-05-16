import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/core/services/cart_service.dart'; // IMPORT CART SERVICE

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Panggil instance cart
  final CartService _cart = CartService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Cart', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppColors.error),
            onPressed: () {
              // FUNGSI HAPUS SEMUA ISI KERANJANG
              setState(() {
                _cart.clearCart();
              });
            },
          ),
        ],
      ),
      body: _cart.items.isEmpty
          ? const Center(child: Text('Keranjang masih kosong', style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cart.items.length,
              itemBuilder: (context, index) {
                final item = _cart.items[index];
                return _buildCartItem(item, index);
              },
            ),
          ),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.restaurant, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(item['desc'], style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 8),
                Text('\$${item['price'].toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Pengatur Quantity dinamis
          Row(
            children: [
              _qtyButton(Icons.remove, () {
                setState(() {
                  if (_cart.items[index]['qty'] > 1) {
                    _cart.items[index]['qty']--;
                  } else {
                    _cart.items.removeAt(index); // Hapus kalau qty jadi 0
                  }
                });
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _qtyButton(Icons.add, () {
                setState(() {
                  _cart.items[index]['qty']++;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.outlineVariant)),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${_cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow('Tax (10%)', '\$${_cart.tax.toStringAsFixed(2)}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          _summaryRow('Total Order', '\$${_cart.total.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // FUNGSI CHECKOUT NANTI DI SINI
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing Payment...')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Checkout Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(fontSize: isTotal ? 22 : 16, fontWeight: FontWeight.bold, color: isTotal ? AppColors.primary : AppColors.onSurface)),
      ],
    );
  }
}
