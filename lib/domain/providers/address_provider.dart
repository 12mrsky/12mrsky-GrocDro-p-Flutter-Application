import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressProvider extends ChangeNotifier {
  static const String _key = 'addresses';

  final List<Map<String, String>> _addresses = [];

  List<Map<String, String>> get addresses => List.unmodifiable(_addresses);

  AddressProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      final decoded = List<Map<String, dynamic>>.from(json.decode(data));
      _addresses
        ..clear()
        ..addAll(decoded.map((e) => e.map(
              (k, v) => MapEntry(k, v.toString()),
            )));
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(_addresses));
  }

  void addAddress(Map<String, String> address) {
    _addresses.add(address);
    _save();
    notifyListeners();
  }

  void updateAddress(int index, Map<String, String> address) {
    if (index < 0 || index >= _addresses.length) return;
    _addresses[index] = address;
    _save();
    notifyListeners();
  }

  void deleteAddress(int index) {
    if (index < 0 || index >= _addresses.length) return;
    _addresses.removeAt(index);
    _save();
    notifyListeners();
  }
}
