import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'productos';

  dynamic uploadProduct(Map<String, dynamic> data) {
    var id = Uuid();
    String productId = id.v1();
    data["id"] = productId;
    _firestore.collection(ref).doc(productId).set(data);
  }

  Future<List<DocumentSnapshot>> getProducts() =>
      _firestore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });

  Future<void> deleteProduct(String productId) {
    return _firestore.collection(ref).doc(productId).delete();
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) {
    return _firestore.collection(ref).doc(productId).update(data);
  }

  Future<int> getProductCount() async {
    QuerySnapshot snapshot = await _firestore.collection(ref).get();
    return snapshot.docs.length;
  }
}
