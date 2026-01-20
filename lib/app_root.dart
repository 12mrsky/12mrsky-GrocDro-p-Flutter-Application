import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import '../auth/auth_gate.dart';
import '../domain/providers/cart_provider.dart';

// 🔹 IMPORT SCREENS FOR ROUTES
import 'screens/orders/order_list_screen.dart';
import 'screens/dashboard/address_screen.dart';
import 'screens/checkout/payments_screen.dart';
import 'screens/dashboard/notifications_screen.dart';
import 'screens/dashboard/privacy_screen.dart';
import 'screens/dashboard/help_screen.dart';
import 'screens/dashboard/about_screen.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // ✅ Splash will show ONLY ONCE
  static bool _splashShownOnce = false;

  bool _showSplash = true;
  bool _cartRestored = false; // 🔥 SAFE FLAG

  @override
  void initState() {
    super.initState();

    if (_splashShownOnce) {
      // ❌ Do NOT show splash again (logout case)
      _showSplash = false;
    } else {
      // ✅ First app launch
      _splashShownOnce = true;

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSplash = false;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔁 RESTORE CART ONLY ONCE
    if (!_cartRestored) {
      context.read<CartProvider>().restoreCart();
      _cartRestored = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔹 APP ENTRY
      home: _showSplash ? SplashScreen() : const AuthGate(),

      // 🔹 GLOBAL ROUTES (PROFILE → SCREENS)
      routes: {
        '/orders': (_) => const OrdersListScreen(),
        '/address': (_) => const AddressScreen(),
        '/payments': (_) => const PaymentsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/privacy': (_) => const PrivacyScreen(),
        '/help': (_) => const HelpScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}
