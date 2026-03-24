import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  List<CartItemModel> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  double get shippingCost => subtotal > 500 ? 0.0 : 29.99;
  double get tax => subtotal * 0.05;
  double get total => subtotal + shippingCost + tax;
  bool isInCart(String productId) => _items.containsKey(productId);
  int getQuantity(String productId) => _items[productId]?.quantity ?? 0;

  void addToCart(ProductModel product, {String? selectedColor}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItemModel(
        id: product.id, product: product,
        quantity: 1, selectedColor: selectedColor,
      );
    }
    notifyListeners();
  }

  void removeFromCart(String productId) { _items.remove(productId); notifyListeners(); }

  void increment(String productId) {
    if (_items.containsKey(productId)) { _items[productId]!.quantity++; notifyListeners(); }
  }

  void decrement(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity <= 1) removeFromCart(productId);
      else { _items[productId]!.quantity--; notifyListeners(); }
    }
  }

  void clearCart() { _items.clear(); notifyListeners(); }
}