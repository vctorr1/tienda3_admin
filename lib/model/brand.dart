import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class BrandService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'marcas';

  void createBrand(String name) {
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection(ref).doc(brandId).set({'marca': name});
  }

  Future<List<DocumentSnapshot>> getBrands() =>
      _firestore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) => _firestore
          .collection(ref)
          .where('marca', isEqualTo: suggestion)
          .get()
          .then((snap) {
        return snap.docs;
      });

  Future<void> deleteBrand(String brandId) {
    return _firestore.collection(ref).doc(brandId).delete();
  }
}
