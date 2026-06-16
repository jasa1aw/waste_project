import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razdelchik/models/waste_item.dart';

class AdminWasteService {
  AdminWasteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('waste_items');

  Stream<List<WasteItem>> watchAllItems() {
    return _collection
        .where('isDeleted', isNotEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => WasteItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addItem(WasteItem item) async {
    await _collection.add(item.toMap());
  }

  Future<void> updateItem(WasteItem item) async {
    await _collection.doc(item.id).update(item.toMap());
  }

  Future<void> softDeleteItem(String itemId) async {
    await _collection.doc(itemId).update({'isDeleted': true});
  }
}
