import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UserService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'usuarios';

  Future<int> getUserCount() async {
    QuerySnapshot snapshot = await _firestore.collection(ref).get();
    return snapshot.docs.length;
  }
}
