import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double total;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  // ================= FIRESTORE =================

  /// ✅ Create Order from Firestore document
  factory Order.fromMap(String id, Map<String, dynamic> data) {
    return Order(
      id: id,
      userId: data['userId'] as String,
      items: List<Map<String, dynamic>>.from(
        data['items'] ?? [],
      ),
      total: (data['total'] as num).toDouble(),
      status: data['status'] ?? 'placed',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// ✅ Convert Order to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'total': total,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ================= FASTAPI / MONGODB =================

  /// ✅ Create Order from FastAPI response
  factory Order.fromApiMap(Map<String, dynamic> data) {
    return Order(
      id: data['_id']?.toString() ?? '',
      userId: data['user_id'] ?? '',
      items: List<Map<String, dynamic>>.from(
        data['items'] ?? [],
      ),
      total: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'PLACED',
      createdAt: DateTime.tryParse(
            data['created_at'] ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
