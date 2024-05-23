import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/order_model.dart' as app_model;

class OrderService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'pedidos';

  Future<int> getOrderCount() async {
    QuerySnapshot snapshot = await _firestore.collection(ref).get();
    return snapshot.docs.length;
  }

  Future<List<app_model.Order>> getOrders() async {
    QuerySnapshot snapshot = await _firestore.collection(ref).get();
    return snapshot.docs
        .map((doc) => app_model.Order.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection(ref).doc(orderId).delete();
  }
}
