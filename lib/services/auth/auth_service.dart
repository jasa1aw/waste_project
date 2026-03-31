import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razdelchik/models/app_user.dart';
import 'package:flutter/foundation.dart';
import 'package:razdelchik/services/leaderboard_service.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _leaderboardService = LeaderboardService(
            firestore: firestore ?? FirebaseFirestore.instance);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LeaderboardService _leaderboardService;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'registration_failed',
        message: 'Тіркелгеннен кейін UID алу мүмкін болмады.',
      );
    }

    final user = AppUser(
      id: uid,
      name: name,
      email: email,
      ecoPoints: 0,
      createdAt: DateTime.now(),
    );

    await credential.user?.getIdToken(true);

    try {
      await _upsertUserProfile(user);
      await _leaderboardService.ensureUserEntry(
        userId: user.id,
        displayName: user.name,
      );
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }

      // On some devices token propagation after sign-up is slightly delayed.
      // Use a retry mechanism to wait for the token to propagate.
      bool success = false;
      int retries = 5;
      
      while (retries > 0 && !success) {
        await Future<void>.delayed(const Duration(milliseconds: 1000));
        await credential.user?.getIdToken(true);
        try {
          await _upsertUserProfile(user);
          await _leaderboardService.ensureUserEntry(
            userId: user.id,
            displayName: user.name,
          );
          success = true;
        } on FirebaseException catch (retryError) {
          if (retryError.code == 'permission-denied' && retries > 1) {
            retries--;
            continue;
          }
          debugPrint('registerWithEmail profile set failed after retries: $retryError');
          rethrow;
        }
      }
    } catch (error, stackTrace) {
      debugPrint('registerWithEmail profile set failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid == null) {
      return;
    }

    final profileDoc = await _firestore.collection('users').doc(uid).get();
    String displayName = _extractNameFromEmail(email);

    if (!profileDoc.exists) {
      final fallbackName = _extractNameFromEmail(email);
      displayName = fallbackName;
      final user = AppUser(
        id: uid,
        name: fallbackName,
        email: email,
        ecoPoints: 0,
        createdAt: DateTime.now(),
      );
      await _upsertUserProfile(user);
    } else {
      final map = profileDoc.data();
      displayName = (map?['name'] as String?)?.trim().isNotEmpty == true
          ? map!['name'] as String
          : displayName;
    }

    await _leaderboardService.ensureUserEntry(
      userId: uid,
      displayName: displayName,
    );
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Stream<AppUser?> watchProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return AppUser.fromMap(snapshot.id, snapshot.data()!);
    });
  }

  Future<void> _upsertUserProfile(AppUser user) {
    return _firestore.collection('users').doc(user.id).set({
      ...user.toMap(),
      'role': 'user',
    }, SetOptions(merge: true));
  }

  String _extractNameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) {
      return 'Пайдаланушы';
    }

    return local.length >= 2 ? local : 'Пайдаланушы';
  }
}
