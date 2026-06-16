import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:razdelchik/models/audit_log_entry.dart';

class AdminAuditService {
  final FirebaseFirestore _firestore;

  AdminAuditService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Streams all audit log entries ordered by timestamp descending.
  /// Optional [filterAction] and date range filters are applied client-side.
  Stream<List<AuditLogEntry>> watchLogs({
    String? filterAction,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final query = _firestore
        .collection('adminAuditLog')
        .orderBy('timestamp', descending: true);

    return query.snapshots().map((snapshot) {
      final entries = snapshot.docs
          .map((doc) => AuditLogEntry.fromMap(doc.id, doc.data()))
          .toList();

      return entries.where((e) {
        if (filterAction != null &&
            filterAction.isNotEmpty &&
            filterAction != 'Барлығы' &&
            e.action != filterAction) {
          return false;
        }
        if (fromDate != null &&
            e.timestamp.isBefore(
              DateTime(fromDate.year, fromDate.month, fromDate.day),
            )) {
          return false;
        }
        if (toDate != null &&
            e.timestamp.isAfter(
              DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59),
            )) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  /// Exports [entries] to a CSV file in the temp directory.
  /// Returns the file path of the written CSV.
  Future<String> exportToCsv(List<AuditLogEntry> entries) async {
    final dir = await getTemporaryDirectory();
    final fileName =
        'audit_log_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$fileName');

    final buffer = StringBuffer();
    // Header
    buffer.writeln('id,adminEmail,action,targetEntity,details,timestamp');

    for (final e in entries) {
      buffer.writeln(
        '${_csvField(e.id)},'
        '${_csvField(e.adminEmail)},'
        '${_csvField(e.action)},'
        '${_csvField(e.targetEntity)},'
        '${_csvField(e.details)},'
        '${_csvField(e.timestamp.toIso8601String())}',
      );
    }

    await file.writeAsString(buffer.toString());
    return file.path;
  }

  /// Wraps a field value in double quotes and escapes inner double quotes.
  String _csvField(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
