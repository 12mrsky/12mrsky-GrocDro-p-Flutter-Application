// lib/screens/checkout/checkout_screen.dart
// ✅ Razorpay integrated
// ❌ No cart / address / order logic changed

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../domain/providers/cart_provider.dart';
import '../orders/order_success_screen.dart';
import '../dashboard/product_details_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Razorpay _razorpay;

  int selectedAddressIndex = 0;

  final List<Map<String, String>> addresses = [
    {
      "title": "Home",
      "address": "123, Demo Street\nCity, State - 000000",
    },
    {
      "title": "Office",
      "address": "IT Park, Phase 2\nCity, State - 000000",
    },
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final cart = context.read<CartProvider>();
    cart.placeOrder();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderSuccessScreen(),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment failed")),
    );
  }

  void _startPayment(int amount) {
    final options = {
      'key': 'RAZORPAY_KEY_HERE', // 🔥 put your key
      'amount': amount * 100,
      'currency': 'INR',
      'name': 'GrocDrop',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9999999999',
        'email': 'demo@email.com',
      },
    };
    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    const int deliveryFee = 40;
    const int savings = 20;
    final int subtotal = cart.totalAmount;
    final int totalPayable = subtotal + deliveryFee - savings;

    final selectedAddress = addresses[selectedAddressIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _SectionTitle("Delivery Address"),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(selectedAddress['title']!),
                    subtitle: Text(selectedAddress['address']!),
                    trailing: TextButton(
                      onPressed: () => _showAddressSheet(context),
                      child: const Text("Change"),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _SectionTitle("Items"),

                ...items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                product: {
                                  "_id": item.id,
                                  "name": item.name,
                                  "image": item.image,
                                  "price": item.price,
                                  "desc": "Fresh & Quality Product",
                                },
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          item.image,
                          width: 40,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          Text("₹${item.price} x ${item.quantity}"),
                      trailing: Text(
                        "₹${item.price * item.quantity}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _SectionTitle("Price Details"),
                _PriceRow("Subtotal", subtotal),
                _PriceRow("Delivery Fee", deliveryFee),
                _PriceRow("Savings", -savings),
                const Divider(),
                _PriceRow(
                  "Total Payable",
                  totalPayable,
                  isBold: true,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          /// 💳 PAY BAR (RAZORPAY)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Amount Payable"),
                    Text(
                      "₹$totalPayable",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _startPayment(totalPayable),
                    child: Text("Pay ₹$totalPayable"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: List.generate(addresses.length, (index) {
          final addr = addresses[index];
          return RadioListTile<int>(
            value: index,
            groupValue: selectedAddressIndex,
            onChanged: (v) {
              setState(() => selectedAddressIndex = v!);
              Navigator.pop(context);
            },
            title: Text(addr['title']!),
            subtitle: Text(addr['address']!),
          );
        }),
      ),
    );
  }
}

/// -------- HELPERS --------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isBold;

  const _PriceRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 16 : 14,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(
            value >= 0 ? "₹$value" : "-₹${value.abs()}",
            style: style,
          ),
        ],
      ),
    );
  }
}
