import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  String id;
  String customerId;
  List<dynamic> items;
  String status;

  Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.status,
  });

  factory Order.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      customerId: data['userId'] ?? '',
      items: data['carrito'] ?? [],
      status: data['status'] ?? '',
    );
  }
}
