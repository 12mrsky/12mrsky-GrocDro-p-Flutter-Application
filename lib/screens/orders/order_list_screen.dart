import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../domain/providers/order_provider.dart';
import 'order_details_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(OrderProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = provider.orders[index];

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            title: Text(
              "₹${order.total}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: order.status.toLowerCase() == 'delivered'
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textMuted,
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(
                    order: {
                      "items": order.items,
                      "total_amount": order.total.toInt(),
                      "status": order.status,
                      "created_at":
                          order.createdAt.toIso8601String(),
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
