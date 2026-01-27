import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/cart_provider.dart';

class ApiService {
  // 🔁 CHANGE THIS FLAG ONLY
  static const bool isProd = true;

  // 🌐 BASE URL
  static const String baseUrl = isProd
      ? "https://one2mrsky-grocdro-p-flutter-application-x6qh.onrender.com"
      : "http://192.168.201.46:8000";

  // ================= PRODUCTS =================
  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products"));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      }
    } catch (e) {
      print("FETCH PRODUCTS ERROR: $e");
    }
    return [];
  }

  // ================= CART =================
  static Future<void> saveCart({
    required List<CartItem> items,
  }) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/cart/save"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": "demo_user",
          "items": items
              .map(
                (e) => {
                  "product_id": e.id,
                  "name": e.name,
                  "price": e.price,
                  "quantity": e.quantity,
                  "image": e.image,
                },
              )
              .toList(),
        }),
      );
    } catch (e) {
      print("SAVE CART ERROR: $e");
    }
  }

  static Future<Map<String, dynamic>> getCart(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/cart/$userId"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("GET CART ERROR: $e");
    }
    return {"user_id": userId, "items": []};
  }

  // ================= ORDERS =================
  static Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/orders/$userId"));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
    } catch (e) {
      print("GET ORDERS ERROR: $e");
    }
    return [];
  }

  // ================= ADDRESSES =================
  static Future<List<dynamic>> getAddresses(String userId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/addresses/$userId"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("GET ADDRESSES ERROR: $e");
    }
    return [];
  }

  static Future<void> addAddress(Map<String, dynamic> data) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/addresses"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
    } catch (e) {
      print("ADD ADDRESS ERROR: $e");
    }
  }

  static Future<void> updateAddress(
    String addressId,
    Map<String, dynamic> data,
  ) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/addresses/$addressId"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
    } catch (e) {
      print("UPDATE ADDRESS ERROR: $e");
    }
  }

  static Future<void> deleteAddress(String addressId) async {
    try {
      await http.delete(
        Uri.parse("$baseUrl/addresses/$addressId"),
      );
    } catch (e) {
      print("DELETE ADDRESS ERROR: $e");
    }
  }

  // ================= PINCODE =================
  static Future<Map<String, dynamic>> checkPincode(String pincode) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/pincode/$pincode"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("PINCODE CHECK ERROR: $e");
    }
    return {"serviceable": false};
  }

  // ================= PAYMENT =================
  static Future<Map<String, dynamic>> createPaymentOrder(int amount) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/payment/create-order"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount,
          "currency": "INR",
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("CREATE PAYMENT ORDER ERROR: $e");
    }
    return {};
  }

  // ================= INVOICE =================
  static Future<String?> downloadInvoice(String orderId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/invoice/$orderId"));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print("DOWNLOAD INVOICE ERROR: $e");
    }
    return null;
  }

  // ================= ADMIN =================
  static Future<bool> addProduct({
    required String name,
    required double price,
    required int quantity,
    required String category,
    required String image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/add-product"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "price": price,
          "quantity": quantity,
          "category": category,
          "image": image,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ADD PRODUCT ERROR: $e");
      return false;
    }
  }
}