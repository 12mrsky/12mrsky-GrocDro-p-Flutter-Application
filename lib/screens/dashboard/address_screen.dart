import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/address_provider.dart';
import 'add_edit_address_screen.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Addresses"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditAddressScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: provider.addresses.isEmpty
          ? const Center(
              child: Text("No address added"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.addresses.length,
              itemBuilder: (context, index) {
                final address = provider.addresses[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(address['Address']!),
                    subtitle: Text(
                      "${address['street']}, ${address['city']} - ${address['pincode']}",
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text("Edit"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditAddressScreen(
                                address: address,
                                index: index,
                              ),
                            ),
                          );
                        } else {
                          provider.deleteAddress(index);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
