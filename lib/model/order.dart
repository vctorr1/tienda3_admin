import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'pedidos';

  Future<int> getOrderCount() async {
    QuerySnapshot snapshot = await _firestore.collection(ref).get();
    return snapshot.docs.length;
  }
}
