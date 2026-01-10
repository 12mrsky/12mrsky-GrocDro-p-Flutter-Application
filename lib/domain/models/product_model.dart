class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image; // asset path or URL
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
  });

  /// ✅ Create Product from Map (Firestore or local data)
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      category: data['category'] as String,
      image: data['image'] as String,
      description: data['description'] ?? '',
    );
  }

  /// ✅ Convert Product to Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
    };
  }
}
