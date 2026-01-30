import 'package:flutter/material.dart';
import '../dashboard/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/about'),
      appBar: AppBar(
        title: const Text("About GrocDrop"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: const Center(
        child: Text("GrocDrop v1.0\nFast Grocery Delivery"),
      ),
    );
  }
}