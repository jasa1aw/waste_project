import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razdelchik/models/leaderboard_entry.dart';

class LeaderboardService {
  LeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _leaderboard =>
      _firestore.collection('leaderboard_public');

  Stream<List<LeaderboardEntry>> watchTopUsers({int limit = 50}) {
    return _leaderboard
        .orderBy('ecoPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaderboardEntry.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<LeaderboardEntry?> watchMyEntry(String userId) {
    return _leaderboard.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return LeaderboardEntry.fromMap(snapshot.id, snapshot.data()!);
    });
  }

  Future<void> ensureUserEntry({
    required String userId,
    required String displayName,
  }) async {
    await _leaderboard.doc(userId).set({
      'userId': userId,
      'displayName': displayName,
      'ecoPoints': 0,
      'scansCount': 0,
      'streakDays': 0,
      'lastScanDay': '',
      'lastActiveAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}
