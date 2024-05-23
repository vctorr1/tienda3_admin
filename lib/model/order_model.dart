import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String customerId;
  final List<Map<String, dynamic>>
      items; // Lista de mapas con detalles del producto
  String status;

  Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.status,
  });

  factory Order.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      customerId: data['userId'],
      items: List<Map<String, dynamic>>.from(data['carrito']),
      status: data['status'],
    );
  }
}
