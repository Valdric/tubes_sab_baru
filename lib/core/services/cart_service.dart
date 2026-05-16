class CartService {
  // Bikin Singleton biar datanya global dan gak keriset pas pindah halaman
  static final CartService instance = CartService._internal();
  CartService._internal();

  List<Map<String, dynamic>> items = [];

  // Fungsi tambah ke keranjang
  void addToCart(String name, String priceStr, String desc) {
    // Cek kalau barang udah ada, tambahin Qty-nya aja
    int index = items.indexWhere((item) => item['name'] == name);
    if (index != -1) {
      items[index]['qty']++;
    } else {
      // Bersihin simbol $ biar bisa dihitung
      double price = double.tryParse(priceStr.replaceAll('\$', '')) ?? 0.0;
      items.add({
        'name': name,
        'price': price,
        'qty': 1,
        'desc': desc,
      });
    }
  }

  // Perhitungan Otomatis
  int get totalItems => items.fold(0, (sum, item) => sum + (item['qty'] as int));
  double get subtotal => items.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
  double get tax => subtotal * 0.1; // Pajak 10%
  double get total => subtotal + tax;

  // Hapus semua
  void clearCart() {
    items.clear();
  }
}
