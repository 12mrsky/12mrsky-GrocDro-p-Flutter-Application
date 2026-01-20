import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About GrocDrop")),
      body: const Center(
        child: Text("GrocDrop v1.0\nFast Grocery Delivery"),
      ),
    );
  }
}
