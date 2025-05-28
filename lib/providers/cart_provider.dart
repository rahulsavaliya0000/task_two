import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  double _discountAmount = 0.0;

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  double get totalAmountBeforeDiscount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  double get discountAmount => _discountAmount;

  double get totalAmount => totalAmountBeforeDiscount - _discountAmount;

  void addItem(Product product) {
    final productId = product.id.toString();
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items[productId] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;
    if (newQuantity > 0) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: newQuantity,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    _items.update(
      productId,
      (existing) => CartItem(
        product: existing.product,
        quantity: existing.quantity + 1,
      ),
    );
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    final current = _items[productId]!;
    if (current.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void applyDiscount(double percent) {
    percent = percent.clamp(0.0, 1.0);
    _discountAmount = totalAmountBeforeDiscount * percent;
    notifyListeners();
  }

  void removeDiscount() {
    _discountAmount = 0.0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discountAmount = 0.0;
    notifyListeners();
  }
}
