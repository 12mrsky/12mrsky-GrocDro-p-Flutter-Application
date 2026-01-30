import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id;
  final String name;
  final String image;
  final int price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "price": price,
        "quantity": quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        name: json['name'],
        image: json['image'],
        price: json['price'],
        quantity: json['quantity'],
      );
}

enum CartAction { none, added, maxReached }

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  CartAction lastAction = CartAction.none;
  static const int maxQty = 100;

  CartProvider() {
    _loadLocalCart();
  }

  Map<String, CartItem> get items => _items;

  int get totalItems =>
      _items.values.fold(0, (sum, e) => sum + e.quantity);

  int get totalAmount =>
      _items.values.fold(0, (sum, e) => sum + e.price * e.quantity);

  /// 🔁 AUTO-RESTORE CART FROM BACKEND
  Future<void> restoreCart() async {
    final data = await ApiService.getCart("demo_user");

    _items.clear();

    if (data['items'] is List) {
      for (final item in data['items']) {
        _items[item['product_id']] = CartItem(
          id: item['product_id'],
          name: item['name'],
          image: item['image'] ?? '',
          price: item['price'],
          quantity: item['quantity'],
        );
      }
    }

    await _saveLocalCart();
    notifyListeners();
  }

  void addItem({
    required String id,
    required String name,
    required String image,
    required int price,
  }) {
    if (_items.containsKey(id)) {
      increaseQty(id);
      return;
    }

    _items[id] = CartItem(
      id: id,
      name: name,
      image: image,
      price: price,
    );

    lastAction = CartAction.added;
    _persistCart();
    notifyListeners();
  }

  void increaseQty(String id) {
    final item = _items[id];
    if (item == null) return;

    if (item.quantity >= maxQty) {
      lastAction = CartAction.maxReached;
      notifyListeners();
      return;
    }

    item.quantity++;
    lastAction = CartAction.added;
    _persistCart();
    notifyListeners();
  }

  void decreaseQty(String id) {
    final item = _items[id];
    if (item == null) return;

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(id);
    }

    lastAction = CartAction.none;
    _persistCart();
    notifyListeners();
  }

  void placeOrder() {
    _items.clear();
    _persistCart();
    notifyListeners();
  }

  /// BACKEND + LOCAL SAVE
  Future<void> _persistCart() async {
    await ApiService.saveCart(items: _items.values.toList());
    await _saveLocalCart();
  }

  /// LOCAL CACHE
  Future<void> _saveLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData =
        jsonEncode(_items.map((k, v) => MapEntry(k, v.toJson())));
    prefs.setString('local_cart', jsonData);
  }

  Future<void> _loadLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('local_cart');

    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _items[key] = CartItem.fromJson(value);
      });
      notifyListeners();
    }
  }
}