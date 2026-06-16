import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razdelchik/models/app_user.dart';

class AdminUserService {
  AdminUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<AppUser>> watchAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .where((user) => user.name.isNotEmpty || user.email.isNotEmpty)
          .toList();
    });
  }

  Future<void> toggleBlock(String userId, bool block, {String adminEmail = ''}) async {
    await _firestore.collection('users').doc(userId).update({
      'isBlocked': block,
    });
    await _firestore.collection('adminAuditLog').add({
      'adminEmail': adminEmail,
      'action': block ? 'BLOCK_USER' : 'UNBLOCK_USER',
      'targetUserId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> adjustEcoPoints(
    String adminEmail,
    String userId,
    int delta,
    String reason,
  ) async {
    final userRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final current = (snap.data()?['ecoPoints'] as num?)?.toInt() ?? 0;
      tx.update(userRef, {'ecoPoints': current + delta});
    });
    await _firestore.collection('adminAuditLog').add({
      'adminEmail': adminEmail,
      'action': 'adjust_eco_points',
      'targetUserId': userId,
      'delta': delta,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
