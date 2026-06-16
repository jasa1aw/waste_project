import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razdelchik/models/scan_record.dart';

class AdminScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ScanRecord>> watchAllScans() {
    return _firestore
        .collection('scan_history')
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScanRecord.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> deleteScan(String adminEmail, String scanId) async {
    await _firestore.collection('scan_history').doc(scanId).delete();
    await _firestore.collection('adminAuditLog').add({
      'adminEmail': adminEmail,
      'action': 'delete_scan',
      'targetScanId': scanId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Returns a map of uid → display label (name if set, else email, else uid).
  Future<Map<String, String>> getUserDisplayNames() async {
    final snapshot = await _firestore.collection('users').get();
    final Map<String, String> result = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final name = (data['name'] as String?)?.trim() ?? '';
      final email = (data['email'] as String?)?.trim() ?? '';
      result[doc.id] = name.isNotEmpty ? name : (email.isNotEmpty ? email : doc.id);
    }
    return result;
  }

  Future<Map<String, int>> getDailyScansLast30Days() async {
    final since = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _firestore
        .collection('scan_history')
        .where('scannedAt', isGreaterThanOrEqualTo: since.toIso8601String())
        .get();

    final Map<String, int> counts = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final raw = data['scannedAt'] as String? ?? '';
      final dt = DateTime.tryParse(raw);
      if (dt == null) continue;
      final key =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }
}
