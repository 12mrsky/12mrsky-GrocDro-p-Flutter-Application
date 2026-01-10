// order_history_screen.dart
// ✅ Amazon / Flipkart–style Orders
// ✅ Thumbnails + Re-order + Cancel UI + Sticky Filter
// ❌ NO backend / logic changes

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../domain/services/api_service.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String selectedFilter = "ALL";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view orders")),
      );
    }

    final userId = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: _buildFilterBar(),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getOrders(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}"));
          }

          final allOrders = snapshot.data ?? [];

          final orders = selectedFilter == "ALL"
              ? allOrders
              : allOrders
                  .where((o) =>
                      (o['status'] ?? '') ==
                      selectedFilter)
                  .toList();

          if (orders.isEmpty) {
            return const Center(
              child: Text("No orders found"),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.fromLTRB(12, 12, 12, 20),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i];
              final status = order['status'] ?? 'PLACED';
              final total = order['total_amount'];
              final date = DateTime.parse(order['created_at']);
              final items = order['items'] ?? [];

              final isDelivered = status == "DELIVERED";

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderDetailsScreen(order: order),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${i + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            _StatusChip(status),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          DateFormat(
                            "dd MMM yyyy • hh:mm a",
                          ).format(date),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🖼 ITEM THUMBNAILS
                        if (items.isNotEmpty)
                          SizedBox(
                            height: 54,
                            child: ListView.builder(
                              scrollDirection:
                                  Axis.horizontal,
                              itemCount: items.length,
                              itemBuilder: (_, j) {
                                final it = items[j];
                                return Container(
                                  margin:
                                      const EdgeInsets.only(
                                          right: 8),
                                  padding:
                                      const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors
                                            .grey.shade300),
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                  ),
                                  child: Image.network(
                                    it['image'] ?? '',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            const Icon(
                                      Icons.image_not_supported,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 12),

                        /// TOTAL
                        Row(
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                  color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              "₹$total",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// ACTION BUTTONS
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                // UI only (no logic)
                              },
                              child: const Text("Re-order"),
                            ),
                            const SizedBox(width: 10),
                            if (!isDelivered)
                              OutlinedButton(
                                onPressed: () {
                                  // UI only (no logic)
                                },
                                style:
                                    OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(
                                      color: Colors.red),
                                ),
                                child:
                                    const Text("Cancel"),
                              ),
                            const Spacer(),
                            const Text(
                              "View details",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔘 FILTER BAR
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _FilterChip("ALL"),
          _FilterChip("PLACED"),
          _FilterChip("DELIVERED"),
        ],
      ),
    );
  }

  Widget _FilterChip(String label) {
    final bool isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedFilter = label;
          });
        },
      ),
    );
  }
}

/// 🏷 STATUS CHIP
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final bool delivered = status == "DELIVERED";

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: delivered
            ? Colors.green.shade100
            : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: delivered ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}
