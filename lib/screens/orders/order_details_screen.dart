import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/invoice_generator.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    // ================= SAFE DATA PARSING =================
    final List<dynamic> items =
        (order['items'] as List<dynamic>?) ?? [];

    final int total =
        (order['total_amount'] as num?)?.toInt() ?? 0;

    final String status =
        (order['status'] ?? 'PLACED').toString().toUpperCase();

    final DateTime date = DateTime.tryParse(
          order['created_at']?.toString() ?? '',
        ) ??
        DateTime.now();
    // =====================================================

    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔹 ORDER SUMMARY
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat("dd MMM yyyy • hh:mm a").format(date),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Chip(
                      label: Text(
                        status,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: status == "DELIVERED"
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 ITEMS LIST
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        "No items found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 24),
                      itemBuilder: (_, i) {
                        final item =
                            items[i] as Map<String, dynamic>? ?? {};

                        final int price =
                            (item['price'] as num?)?.toInt() ??
                                0;
                        final int qty =
                            (item['quantity'] as num?)?.toInt() ??
                                1;

                        return Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']?.toString() ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹$price × $qty",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "₹${price * qty}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),

          // 🔹 ACTIONS + TOTAL
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹$total",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff00A86B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("Invoice"),
                        onPressed: () async {
                          await InvoiceGenerator.generate(
                            order: order,
                            items: List<Map<String, dynamic>>.from(
                                items),
                            address: const {
                              "title": "Delivery Address",
                              "address":
                                  "Saved delivery address",
                            },
                          );

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Invoice downloaded"),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 🔁 UI ONLY – backend logic unchanged
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Re-order coming soon"),
                            ),
                          );
                        },
                        child: const Text("Re-Order"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
