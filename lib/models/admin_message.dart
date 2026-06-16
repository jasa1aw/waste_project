import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMessage {
  const AdminMessage({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.type,
    required this.message,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  final String id;
  final String userId;
  final String userEmail;
  final String type;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  bool get isUnread => status == 'unread';
  bool get isResolved => status == 'resolved';

  factory AdminMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminMessage(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      type: data['type'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'unread',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      resolvedBy: data['resolvedBy'] as String?,
    );
  }
}
