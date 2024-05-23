import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String customerId;
  final List<dynamic> items;

  Order({
    required this.id,
    required this.customerId,
    required this.items,
  });

  factory Order.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      customerId: data['userId'],
      items: data['carrito'] ?? [],
    );
  }
}
