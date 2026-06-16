import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razdelchik/models/admin_message.dart';

class AdminMessagesService {
  AdminMessagesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('admin_messages');

  Stream<List<AdminMessage>> getMessages() {
    return _col.snapshots().map((snap) {
      final messages = snap.docs.map(AdminMessage.fromDoc).toList();
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return messages;
    });
  }

  Stream<int> watchUnreadCount() {
    return _col.snapshots().map((snap) =>
        snap.docs.where((doc) => doc.data()['status'] == 'unread').length);
  }

  Future<void> markAsRead(String messageId) {
    return _col.doc(messageId).update({'status': 'read'});
  }

  Future<void> resolveMessage(String messageId, String adminUid) {
    return _col.doc(messageId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedBy': adminUid,
    });
  }

  Future<void> deleteMessage(String messageId) {
    return _col.doc(messageId).delete();
  }

  Future<void> sendAppeal({
    required String userId,
    required String userEmail,
    required String message,
  }) {
    return _col.add({
      'userId': userId,
      'userEmail': userEmail,
      'type': 'unblock_request',
      'message': message,
      'status': 'unread',
      'createdAt': FieldValue.serverTimestamp(),
      'resolvedAt': null,
      'resolvedBy': null,
    });
  }
}
