// lib/screens/checkout/checkout_screen.dart
// ✅ Razorpay integrated
// ✅ AddressProvider integrated
// ❌ Cart / order / payment logic unchanged

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../domain/providers/cart_provider.dart';
import '../../domain/providers/address_provider.dart';
import '../orders/order_success_screen.dart';
import '../dashboard/product_details_screen.dart';
import '../map/map_picker_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Razorpay _razorpay;
  int selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    context.read<CartProvider>().placeOrder();
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
      'key': 'RAZORPAY_KEY_HERE',
      'amount': amount * 100,
      'currency': 'INR',
      'name': 'GrocDrop',
      'description': 'Order Payment',
    };
    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    const int deliveryFee = 40;
    const int savings = 20;
    final int totalPayable =
        cart.totalAmount + deliveryFee - savings;

    final bool hasAddress = addresses.isNotEmpty;

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
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(
                      hasAddress
                          ? addresses[selectedAddressIndex]['title']!
                          : "No address added",
                    ),
                    subtitle: Text(
                      hasAddress
                          ? addresses[selectedAddressIndex]['address']!
                          : "Please add a delivery address",
                    ),
                    trailing: TextButton(
                      onPressed: _showAddressSheet,
                      child: Text(hasAddress ? "Change" : "Add"),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _SectionTitle("Items"),

                ...cart.items.values.map(
                  (item) => Card(
                    child: ListTile(
                      leading: Image.network(
                        item.image,
                        width: 40,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      title: Text(item.name),
                      subtitle:
                          Text("₹${item.price} x ${item.quantity}"),
                      trailing: Text(
                        "₹${item.price * item.quantity}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _SectionTitle("Price Details"),
                _PriceRow("Delivery Fee", deliveryFee),
                _PriceRow("Savings", -savings),
                const Divider(),
                _PriceRow("Total Payable", totalPayable,
                    isBold: true),
                const SizedBox(height: 80),
              ],
            ),
          ),

          /// 💳 PAY BAR
          Container(
            padding: const EdgeInsets.all(16),
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
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed:
                      hasAddress ? () => _startPayment(totalPayable) : null,
                  child: Text("Pay ₹$totalPayable"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🏠 ADDRESS SELECT / ADD / EDIT / DELETE
  void _showAddressSheet() {
    final provider = context.read<AddressProvider>();
    final addresses = provider.addresses;

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Address",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...List.generate(addresses.length, (index) {
              final addr = addresses[index];
              return RadioListTile<int>(
                value: index,
                groupValue: selectedAddressIndex,
                title: Text(addr['title']!),
                subtitle: Text(addr['address']!),
                onChanged: (v) {
                  setState(() => selectedAddressIndex = v!);
                  Navigator.pop(context);
                },
                secondary: PopupMenuButton<String>(
                  onSelected: (value) {
                    Navigator.pop(context);
                    if (value == 'edit') {
                      _showAddressForm(editIndex: index);
                    } else if (value == 'delete') {
                      _confirmDelete(index);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(
                        value: 'delete', child: Text("Delete")),
                  ],
                ),
              );
            }),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add New Address"),
              onTap: () {
                Navigator.pop(context);
                _showAddressForm();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ➕ ADD / ✏️ EDIT ADDRESS (WITH MAP PICKER)
  void _showAddressForm({int? editIndex}) async {
    final provider = context.read<AddressProvider>();

    final titleController = TextEditingController(
      text: editIndex != null
          ? provider.addresses[editIndex]['title']
          : '',
    );

    final addressController = TextEditingController(
      text: editIndex != null
          ? provider.addresses[editIndex]['address']
          : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editIndex == null ? "Add Address" : "Edit Address"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: "Full Address"),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("Pick from Map"),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MapPickerScreen(),
                  ),
                );
                if (result != null) {
                  addressController.text = result;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  addressController.text.isEmpty) return;

              final data = {
                "title": titleController.text,
                "address": addressController.text,
              };

              if (editIndex == null) {
                provider.addAddress(data);
                setState(() {
                  selectedAddressIndex =
                      provider.addresses.length - 1;
                });
              } else {
                provider.updateAddress(editIndex, data);
              }

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// 🗑 DELETE CONFIRMATION
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Address"),
        content:
            const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () {
              context.read<AddressProvider>().deleteAddress(index);
              if (selectedAddressIndex > 0) {
                setState(() => selectedAddressIndex--);
              }
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
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
            fontSize: 16, fontWeight: FontWeight.bold),
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
