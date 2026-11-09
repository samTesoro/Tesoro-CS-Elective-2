import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get totalPrice => _items.fold(
        0.0,
        (total, item) => total + item.product.price * item.quantity,
      );

  void add(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void syncProduct(Product product) {
    for (final item in _items) {
      if (item.product.id == product.id) item.product = product;
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  List<CartItem> checkout() {
    final order = _items
        .map((item) => CartItem(product: item.product, quantity: item.quantity))
        .toList();
    _items.clear();
    notifyListeners();
    return order;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
