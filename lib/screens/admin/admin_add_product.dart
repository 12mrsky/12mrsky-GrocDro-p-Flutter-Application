import 'package:flutter/material.dart';
import '../../domain/services/api_service.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final name = TextEditingController();
  final price = TextEditingController();
  final qty = TextEditingController();
  final cat = TextEditingController();
  final img = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);

    final ok = await ApiService.addProduct(
      name: name.text,
      price: double.parse(price.text),
      quantity: int.parse(qty.text),
      category: cat.text,
      image: img.text,
    );

    setState(() => loading = false);

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product Added")));
      Navigator.pop(context);
    }
  }

  Widget f(String t, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          decoration:
              InputDecoration(labelText: t, border: OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            f("Name", name),
            f("Price", price),
            f("Quantity", qty),
            f("Category", cat),
            f("Image URL", img),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: const Text("ADD"),
            )
          ],
        ),
      ),
    );
  }
}