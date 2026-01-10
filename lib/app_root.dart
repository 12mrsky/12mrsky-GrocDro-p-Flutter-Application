import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import '../auth/auth_gate.dart';
import '../domain/providers/cart_provider.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // ✅ Splash will show ONLY ONCE
  static bool _splashShownOnce = false;

  bool _showSplash = true;
  bool _cartRestored = false; // 🔥 ADDED (SAFE FLAG)

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
    return _showSplash ? SplashScreen() : const AuthGate();
  }
}
