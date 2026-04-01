import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Added
import 'package:razdelchik/models/scan_record.dart';
import 'package:razdelchik/models/waste_type.dart';

class StatsSummary {
  const StatsSummary({
    required this.totalItems,
    required this.byType,
    required this.weeklyActivity,
  });

  final int totalItems;
  final Map<WasteType, int> byType;
  final Map<int, int> weeklyActivity;
}

class ScanHistoryService {
  ScanHistoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> addScanRecord(ScanRecord record) async {
    // Critical: save the scan record itself.
    await _firestore.collection('scan_history').add(record.toMap());

    // Secondary: update user stats. Non-critical — don't let
    // failures here surface as a "save failed" error to the user.
    try {
      await _firestore.collection('users').doc(record.userId).update({
        'ecoPoints': FieldValue.increment(record.pointsAwarded),
        'lastScanAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('addScanRecord: user stats update failed: $e');
    }

    // Secondary: sync leaderboard (uses a transaction, can fail on
    // slow networks). Non-critical for the scan save UX.
    try {
      await _syncLeaderboard(record);
    } catch (e) {
      debugPrint('addScanRecord: leaderboard sync failed: $e');
    }
  }

  Future<void> _syncLeaderboard(ScanRecord record) async {
    final todayKey = _dayKey(DateTime.now());
    final yesterdayKey =
        _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final userDoc =
        await _firestore.collection('users').doc(record.userId).get();
    final userName = (userDoc.data()?['name'] as String?)?.trim();
    final displayName =
        (userName != null && userName.isNotEmpty) ? userName : 'Eco User';

    final leaderboardRef =
        _firestore.collection('leaderboard_public').doc(record.userId);

    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(leaderboardRef);
      final data = snapshot.data() ?? <String, dynamic>{};

      final lastScanDay = data['lastScanDay'] as String? ?? '';
      final currentStreak = (data['streakDays'] as num?)?.toInt() ?? 0;
      final newStreak = _nextStreak(
        lastScanDay: lastScanDay,
        todayKey: todayKey,
        yesterdayKey: yesterdayKey,
        currentStreak: currentStreak,
      );

      tx.set(
        leaderboardRef,
        {
          'userId': record.userId,
          'displayName': displayName,
          'ecoPoints': ((data['ecoPoints'] as num?)?.toInt() ?? 0) +
              record.pointsAwarded,
          'scansCount': ((data['scansCount'] as num?)?.toInt() ?? 0) + 1,
          'streakDays': newStreak,
          'lastScanDay': todayKey,
          'lastActiveAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    });
  }

  int _nextStreak({
    required String lastScanDay,
    required String todayKey,
    required String yesterdayKey,
    required int currentStreak,
  }) {
    if (lastScanDay == todayKey) {
      return currentStreak > 0 ? currentStreak : 1;
    }
    if (lastScanDay == yesterdayKey) {
      return currentStreak + 1;
    }
    return 1;
  }

  String _dayKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Stream<List<ScanRecord>> watchRecentScans(String userId, {int limit = 30}) {
    return _firestore
        .collection('scan_history')
        .where('userId', isEqualTo: userId)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ScanRecord.fromMap(doc.id, doc.data()))
          .toList();

      records.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return records;
    });
  }

  Stream<StatsSummary> watchStatsSummary(String userId) {
    return watchRecentScans(userId, limit: 500).map((records) {
      final byType = <WasteType, int>{
        WasteType.plastic: 0,
        WasteType.paper: 0,
        WasteType.glass: 0,
        WasteType.metal: 0,
        WasteType.organic: 0,
        WasteType.unknown: 0,
      };
      final weeklyActivity = <int, int>{
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0
      };

      for (final record in records) {
        byType[record.wasteType] = (byType[record.wasteType] ?? 0) + 1;
        weeklyActivity[record.scannedAt.weekday] =
            (weeklyActivity[record.scannedAt.weekday] ?? 0) + 1;
      }

      return StatsSummary(
        totalItems: records.length,
        byType: byType,
        weeklyActivity: weeklyActivity,
      );
    });
  }
}
