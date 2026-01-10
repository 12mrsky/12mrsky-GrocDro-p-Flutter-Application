import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  // 🔹 ADD PRODUCT
  void addProduct(Map<String, dynamic> product) {
    final index = _items.indexWhere(
      (item) => item.id == product['id'].toString(),
    );

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem.fromProduct(product));
    }
    notifyListeners();
  }

  // 🔹 REMOVE PRODUCT
  void removeProduct(String id) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // 🔹 SET EXACT QUANTITY
  void setProductQuantity(Map<String, dynamic> product, int quantity) {
    final index = _items.indexWhere(
      (item) => item.id == product['id'].toString(),
    );

    if (quantity <= 0) {
      if (index != -1) {
        _items.removeAt(index);
      }
    } else {
      if (index != -1) {
        _items[index].quantity = quantity;
      } else {
        final item = CartItem.fromProduct(product);
        item.quantity = quantity;
        _items.add(item);
      }
    }
    notifyListeners();
  }

  // 🔹 TOTAL PRICE
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  // 🔹 TOTAL ITEMS
  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  // 🔹 CLEAR CART
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // 🔹 SAVE CART TO BACKEND
  Future<void> syncCart(String userId) async {
    await ApiService.saveCart(
      userId: userId,
      items: _items.map((e) => e.toJson()).toList(),
    );
  }

  // 🔹 LOAD CART FROM BACKEND
  Future<void> loadCart(String userId) async {
    final data = await ApiService.getCart(userId);
    _items.clear();

    for (var item in data["items"] ?? []) {
      _items.add(CartItem.fromJson(item));
    }
    notifyListeners();
  }
}
