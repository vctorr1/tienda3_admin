import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/order_model.dart' as order_model;

class OrderService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'pedidos';

  Future<int> getOrderCount() async {
    QuerySnapshot snapshot = await _firestore.collection(ref).get();
    return snapshot.docs.length;
  }

  Future<List<order_model.Order>> getOrders() async {
    QuerySnapshot snapshot = await _firestore.collection(ref).get();
    return snapshot.docs
        .map((doc) => order_model.Order.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection(ref).doc(orderId).delete();
  }

  Future<void> updateOrder(order_model.Order order) async {
    await _firestore.collection(ref).doc(order.id).update({
      'userId': order.customerId,
      'carrito': order.items,
      'status': order.status,
    });
  }

  order_model.Order removeProduct(order_model.Order order, int index) {
    order.items.removeAt(index);
    return order;
  }

  order_model.Order changeOrderStatus(
      order_model.Order order, String newStatus) {
    order.status = newStatus;
    return order;
  }

  Future<int> getCompletedOrderCount() async {
    QuerySnapshot snapshot = await _firestore
        .collection(ref)
        .where('status', isEqualTo: 'Completado')
        .get();
    return snapshot.docs.length;
  }

  Future<double> getTotalRevenue() async {
    QuerySnapshot snapshot = await _firestore
        .collection(ref)
        .where('status', isEqualTo: 'Completado')
        .get();
    double totalRevenue = 0;
    for (var doc in snapshot.docs) {
      order_model.Order order = order_model.Order.fromDocumentSnapshot(doc);
      double orderTotal =
          order.items.fold(0, (sum, item) => sum + (item['precio'] ?? 0) / 100);
      totalRevenue += orderTotal;
    }
    return totalRevenue;
  }
}
