import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razdelchik/models/recycling_point.dart';

class AdminRecyclingService {
  final FirebaseFirestore _firestore;

  AdminRecyclingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('recycling_points');

  Stream<List<RecyclingPoint>> watchAllPoints() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RecyclingPoint.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addPoint(RecyclingPoint point) async {
    await _collection.add(point.toMap());
  }

  Future<void> updatePoint(RecyclingPoint point) async {
    await _collection.doc(point.id).update(point.toMap());
  }

  Future<void> deletePoint(String pointId) async {
    await _collection.doc(pointId).delete();
  }
}
