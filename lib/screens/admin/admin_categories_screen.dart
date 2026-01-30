import 'package:flutter/material.dart';
import '../../domain/services/api_service.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  List categories = [];
  bool loading = true;

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    categories = await ApiService.getCategories();
    setState(() => loading = false);
  }

  Future<void> addCategory() async {
    if (controller.text.isEmpty) return;

    await ApiService.addCategory(controller.text);
    controller.clear();
    Navigator.pop(context);
    load();
  }

  void openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Category name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: addCategory, child: const Text("Add")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final c = categories[i];

                return Dismissible(
                  key: ValueKey(c['_id']),
                  background: Container(color: Colors.red),
                  onDismissed: (_) async {
                    await ApiService.deleteCategory(c['_id']);
                    load();
                  },
                  child: ListTile(
                    title: Text(c['name']),
                  ),
                );
              },
            ),
    );
  }
}