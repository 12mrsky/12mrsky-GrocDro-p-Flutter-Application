import 'package:flutter/material.dart';

import '../screens/dashboard/cart_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/orders/order_success_screen.dart';

class AppRoutes {
  // 🔹 Route names (use everywhere)
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String orderSuccess = '/order-success';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
        );

      case orders:
        return MaterialPageRoute(
          builder: (_) => const OrderHistoryScreen(),
        );

      case orderSuccess:
        return MaterialPageRoute(
          builder: (_) => const OrderSuccessScreen(),
        );

      default:
        // ✅ Safe fallback (prevents crash / black screen)
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Page not found',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
    }
  }
}
