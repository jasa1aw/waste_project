import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogEntry {
  final String id;
  final String adminEmail;
  final String action;
  final String targetEntity;
  final String details;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.id,
    required this.adminEmail,
    required this.action,
    required this.targetEntity,
    required this.details,
    required this.timestamp,
  });

  factory AuditLogEntry.fromMap(String id, Map<String, dynamic> map) {
    // Combine targetUserId / targetScanId into one field
    final targetEntity = (map['targetUserId'] as String?)?.isNotEmpty == true
        ? map['targetUserId'] as String
        : (map['targetScanId'] as String?) ?? '';

    // Build a readable details string from delta / reason / remaining keys
    final parts = <String>[];
    if (map['delta'] != null) parts.add('Өзгеріс: ${map['delta']}');
    if (map['reason'] != null && (map['reason'] as String).isNotEmpty) {
      parts.add('Себеп: ${map['reason']}');
    }
    final knownKeys = {
      'adminEmail',
      'action',
      'targetUserId',
      'targetScanId',
      'delta',
      'reason',
      'timestamp',
    };
    for (final entry in map.entries) {
      if (!knownKeys.contains(entry.key) && entry.value != null) {
        parts.add('${entry.key}: ${entry.value}');
      }
    }
    final details = parts.join(', ');

    // Parse timestamp — Firestore stores it as a Timestamp object (serverTimestamp),
    // but older docs or manual writes may use an ISO-8601 String.
    DateTime ts;
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawTs is String && rawTs.isNotEmpty) {
      ts = DateTime.tryParse(rawTs) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      ts = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return AuditLogEntry(
      id: id,
      adminEmail: map['adminEmail'] as String? ?? '',
      action: map['action'] as String? ?? '',
      targetEntity: targetEntity,
      details: details,
      timestamp: ts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminEmail': adminEmail,
      'action': action,
      'targetEntity': targetEntity,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
