import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/address_provider.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Map<String, String>? address;
  final int? index;

  const AddEditAddressScreen({
    super.key,
    this.address,
    this.index,
  });

  @override
  State<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController pincodeController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.address?['name']);
    streetController =
        TextEditingController(text: widget.address?['street']);
    cityController =
        TextEditingController(text: widget.address?['city']);
    pincodeController =
        TextEditingController(text: widget.address?['pincode']);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null
            ? "Add Address"
            : "Edit Address"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field("Name", nameController),
              _field("Street", streetController),
              _field("City", cityController),
              _field("Pincode", pincodeController,
                  keyboard: TextInputType.number),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final address = {
                        "name": nameController.text,
                        "street": streetController.text,
                        "city": cityController.text,
                        "pincode": pincodeController.text,
                      };

                      if (widget.address == null) {
                        provider.addAddress(address);
                      } else {
                        provider.updateAddress(widget.index!, address);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Address"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
