// p_card.dart  ✅ OVERFLOW FIX (STABLE – NO OVERFLOW EVER)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/cart_provider.dart';
import 'product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({
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

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE (FIXED HEIGHT)
            SizedBox(
              height: 95,
              child: Center(
                child: Image.network(
                  product['image'],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// NAME (FIXED LINES)
            Text(
              product['name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            /// DESC (OPTIONAL, FIXED)
            Text(
              product['desc'] ?? 'Fresh & Quality Product',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 6),

            /// PRICE + CART (FIXED HEIGHT ROW)
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "₹${product['price']}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),

                  qty == 0
                      ? _addButton(cart, productId)
                      : _qtyController(cart, productId, qty),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton(CartProvider cart, String productId) {
    return SizedBox(
      width: 68,
      height: 32,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          cart.addItem(
            id: productId,
            name: product['name'],
            image: product['image'],
            price: product['price'],
          );
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "ADD",
            style: TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _qtyController(
    CartProvider cart,
    String productId,
    int qty,
  ) {
    return SizedBox(
      width: 90,
      height: 32,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _iconBtn(
              icon: Icons.remove,
              onTap: () {
                HapticFeedback.selectionClick();
                cart.decreaseQty(productId);
              },
            ),
            SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  qty.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            _iconBtn(
              icon: Icons.add,
              onTap: () {
                if (qty >= CartProvider.maxQty) {
                  HapticFeedback.heavyImpact();
                } else {
                  HapticFeedback.selectionClick();
                }
                cart.increaseQty(productId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
