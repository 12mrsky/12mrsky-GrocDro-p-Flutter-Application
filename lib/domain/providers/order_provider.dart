import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocdrop/domain/services/api_service.dart';
import '../models/order_model.dart' as app_models;

class OrderProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<app_models.Order> _orders = [];
  bool _isLoading = false;

  /// Public getters
  List<app_models.Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  /// ✅ FETCH USER ORDERS (FROM FASTAPI)
  Future<void> fetchOrders() async {
  try {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;

    if (user == null) {
      _orders.clear();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final data = await ApiService.getOrders(user.uid);

    _orders.clear();
    _orders.addAll(
      data.map((e) => app_models.Order.fromApiMap(e)),
    );
  } catch (e) {
    debugPrint("Fetch orders error: $e");
  } finally {
    _isLoading = false; // 🔥 GUARANTEED STOP
    notifyListeners();
  }
}
}