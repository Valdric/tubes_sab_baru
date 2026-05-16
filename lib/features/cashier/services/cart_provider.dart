import 'package:flutter/material.dart';

class CartItem {
  final String menuId;
  final String name;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.menuId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String menuId, String name, double price, String? imageUrl) {
    if (_items.containsKey(menuId)) {
      _items.update(
        menuId,
        (existing) => CartItem(
          menuId: existing.menuId,
          name: existing.name,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        menuId,
        () => CartItem(
          menuId: menuId,
          name: name,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String menuId, int quantity) {
    if (!_items.containsKey(menuId)) return;
    if (quantity <= 0) {
      removeItem(menuId);
    } else {
      _items.update(
        menuId,
        (existing) => CartItem(
          menuId: existing.menuId,
          name: existing.name,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: quantity,
        ),
      );
      notifyListeners();
    }
  }

  void removeItem(String menuId) {
    _items.remove(menuId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
