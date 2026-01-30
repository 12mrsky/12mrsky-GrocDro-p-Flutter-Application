import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/services/api_service.dart';

class AdminAddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product; // null = add, not null = edit

  const AdminAddProductScreen({super.key, this.product});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final name = TextEditingController();
  final price = TextEditingController();
  final qty = TextEditingController();

  final picker = ImagePicker();

  String category = "Fruits";
  String? imageUrl;

  bool loading = false;

  final categories = [
    "Fruits",
    "Vegetables",
    "Snacks",
    "Beverages",
    "Bakery",
  ];

  @override
  void initState() {
    super.initState();

    /// EDIT MODE PREFILL
    if (widget.product != null) {
      name.text = widget.product!['name'];
      price.text = widget.product!['price'].toString();
      qty.text = widget.product!['quantity'].toString();
      category = widget.product!['category'];
      imageUrl = widget.product!['image'];
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => loading = true);

    final url = await ApiService.uploadImage(File(picked.path));

    setState(() {
      imageUrl = url;
      loading = false;
    });
  }

  Future<void> submit() async {
    if (name.text.isEmpty ||
        price.text.isEmpty ||
        qty.text.isEmpty ||
        imageUrl == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    final parsedPrice = double.tryParse(price.text);
    if (parsedPrice == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid price")));
      return;
    }

    setState(() => loading = true);

    /// EDIT PRODUCT
    if (widget.product != null) {
      await ApiService.updateProduct(widget.product!['_id'], {
        "name": name.text,
        "price": parsedPrice,
        "quantity": int.parse(qty.text),
        "category": category,
        "image": imageUrl,
      });
    }

    /// ADD PRODUCT
    else {
      await ApiService.addProduct(
        name: name.text,
        price: parsedPrice,
        quantity: int.parse(qty.text),
        category: category,
        image: imageUrl!,
      );
    }

    setState(() => loading = false);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget field(String label, TextEditingController c,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Product" : "Add Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: imageUrl == null
                    ? const Center(child: Text("Tap to upload image"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(imageUrl!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            field("Product Name", name),
            field("Price", price, type: TextInputType.number),
            field("Quantity", qty, type: TextInputType.number),

            DropdownButtonFormField(
              value: category,
              items: categories
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
              decoration: InputDecoration(
                labelText: "Category",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? "UPDATE" : "ADD PRODUCT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}