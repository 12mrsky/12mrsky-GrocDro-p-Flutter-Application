import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payments & Refunds")),
      body: const Center(
        child: Text("Payment history coming soon"),
      ),
    );
  }
}
