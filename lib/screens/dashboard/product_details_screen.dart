// product_details_screen.dart
// ✅ SHOW "Cart updated" + GO TO CART AFTER ADD
// ❌ No cart logic changed

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final String productId = product['_id'].toString();

    final int qty = cart.items.containsKey(productId)
        ? cart.items[productId]!.quantity
        : 0;

    void _showCartUpdatedAndGo() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart updated"),
          duration: Duration(milliseconds: 800),
        ),
      );

      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product['image'],
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 60),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              product['name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (product['category'] != null)
              Chip(
                label: Text(product['category']),
              ),

            const SizedBox(height: 12),

            Text(
              product['desc'] ?? 'Fresh & Quality Product',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "₹${product['price']}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            /// QTY CONTROLLER
            if (qty > 0)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () =>
                          cart.decreaseQty(productId),
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          qty.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () =>
                          cart.increaseQty(productId),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            /// ADD TO CART + BUY NOW
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (qty == 0) {
                        cart.addItem(
                          id: productId,
                          name: product['name'],
                          image: product['image'],
                          price: product['price'],
                        );
                      }
                      _showCartUpdatedAndGo();
                    },
                    child: const Text("ADD TO CART"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (qty == 0) {
                        cart.addItem(
                          id: productId,
                          name: product['name'],
                          image: product['image'],
                          price: product['price'],
                        );
                      }
                      _showCartUpdatedAndGo();
                    },
                    child: const Text("BUY NOW"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (qty > 0)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    while (cart.items.containsKey(productId)) {
                      cart.decreaseQty(productId);
                    }
                    _showCartUpdatedAndGo();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("REMOVE FROM CART"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
