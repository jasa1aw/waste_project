import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsService {
  final FirebaseFirestore _db;

  AdminAnalyticsService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<int> getTotalUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.length;
  }

  Future<int> getTotalScans() async {
    final snap = await _db.collection('scan_history').get();
    return snap.docs.length;
  }

  Future<int> getTotalEcoPoints() async {
    final snap = await _db.collection('users').get();
    int total = 0;
    for (final doc in snap.docs) {
      total += (doc.data()['ecoPoints'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  Future<int> getDailyActiveUsers() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final snap = await _db
        .collection('scan_history')
        .where('scannedAt', isGreaterThanOrEqualTo: midnight.toIso8601String())
        .get();
    final userIds = <String>{};
    for (final doc in snap.docs) {
      final uid = doc.data()['userId'] as String?;
      if (uid != null) userIds.add(uid);
    }
    return userIds.length;
  }

  Future<Map<String, int>> getScansByCategory() async {
    final snap = await _db.collection('scan_history').get();
    final result = <String, int>{};
    for (final doc in snap.docs) {
      final category = doc.data()['category'] as String? ?? 'Белгісіз';
      result[category] = (result[category] ?? 0) + 1;
    }
    return result;
  }

  /// Returns a map of ISO date string (YYYY-MM-DD) → scan count for the last 30 days.
  Future<Map<String, int>> getDailyScansLast30Days() async {
    final since = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _db
        .collection('scan_history')
        .where('scannedAt', isGreaterThanOrEqualTo: since.toIso8601String())
        .get();

    final Map<String, int> counts = {};
    for (final doc in snapshot.docs) {
      final raw = doc.data()['scannedAt'] as String? ?? '';
      final dt = DateTime.tryParse(raw);
      if (dt == null) continue;
      final key =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<Map<String, dynamic>>> getTopLeaderboard({int limit = 10}) async {
    try {
      final snap = await _db
          .collection('leaderboard')
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        return {
          'displayName': data['displayName'] as String? ?? '',
          'totalPoints': (data['totalPoints'] as num?)?.toInt() ?? 0,
          'scanCount': (data['scanCount'] as num?)?.toInt() ?? 0,
        };
      }).toList();
    } on FirebaseException catch (e) {
      // Collection may not exist yet or rules may not yet be deployed;
      // return empty list instead of crashing the Analytics screen.
      // ignore: avoid_print
      print('AdminAnalyticsService.getTopLeaderboard: ${e.code} – ${e.message}');
      return [];
    }
  }
}
