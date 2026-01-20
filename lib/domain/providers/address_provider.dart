import 'package:flutter/material.dart';

class AddressProvider extends ChangeNotifier {
  final List<Map<String, String>> _addresses = [];

  List<Map<String, String>> get addresses => _addresses;

  void addAddress(Map<String, String> address) {
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(int index, Map<String, String> address) {
    _addresses[index] = address;
    notifyListeners();
  }

  void deleteAddress(int index) {
    _addresses.removeAt(index);
    notifyListeners();
  }
}
