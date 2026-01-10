class CartItem {
  final String id;
  final String name;
  final int price;
  final String image; // 🔥 comes from product, not backend
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.quantity,
  });

  // 🔹 CREATE FROM PRODUCT MAP (HOME / DETAILS → CART)
  factory CartItem.fromProduct(Map<String, dynamic> product) {
    return CartItem(
      id: product['id'].toString(),
      name: product['name'] ?? '',
      price: product['price'] ?? 0,
      image: product['image'] ?? '', // ✅ FULL IMAGE URL
      category: product['category'] ?? '',
      quantity: 1,
    );
  }

  // 🔹 TOTAL PRICE
  int get totalPrice => price * quantity;

  // 🔹 CONVERT TO JSON (SEND TO FASTAPI)
  // ⚠️ Backend does NOT need image/category
  Map<String, dynamic> toJson() {
    return {
      "product_id": id,
      "name": name,
      "price": price,
      "quantity": quantity,
    };
  }

  // 🔹 CREATE FROM JSON (FROM FASTAPI)
  // ⚠️ Image NOT returned → keep empty safely
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['product_id'].toString(),
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      image: '', // ❌ backend doesn’t send image
      category: '',
      quantity: json['quantity'] ?? 1,
    );
  }
}
