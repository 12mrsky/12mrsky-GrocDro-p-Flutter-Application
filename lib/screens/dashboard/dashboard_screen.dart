// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/cart_provider.dart';
import 'home_tab.dart';
import 'cart_screen.dart';
import 'orders_tab.dart';
import 'profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int index;

  final List<Widget> tabs = const [
    HomeTab(),
    CartScreen(),
    OrdersTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // 🔹 Keeps tab state alive
      body: IndexedStack(
        index: index,
        children: tabs,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,

        // ✅ UPDATED (Material 3 safe)
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor:
            theme.colorScheme.onSurface.withOpacity(0.6),

        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          // 🛒 CART WITH BADGE
          BottomNavigationBarItem(
            label: "Cart",
            icon: Consumer<CartProvider>(
              builder: (_, cart, __) => Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),

                  if (cart.totalItems > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.totalItems.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
