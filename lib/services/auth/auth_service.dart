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

    // Auth user created — profile & leaderboard setup is best-effort.
    // signInWithEmail already backfills the profile if it doesn't exist.
    await credential.user?.getIdToken(true);

    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        await _upsertUserProfile(user);
        await _leaderboardService.ensureUserEntry(
          userId: user.id,
          displayName: user.name,
        );
        return; // Profile setup succeeded
      } on FirebaseException catch (error) {
        if (error.code != 'permission-denied') {
          // Non-permission error — log and skip. Auth user is already created.
          debugPrint('registerWithEmail profile setup error: $error');
          return;
        }
        debugPrint(
            'Profile setup attempt $attempt/5 failed (permission-denied)');
        if (attempt < 5) {
          await Future<void>.delayed(Duration(milliseconds: 800 * attempt));
          await credential.user?.getIdToken(true);
        } else {
          // All retries exhausted — suppress. Profile will be created on
          // next signInWithEmail() which already handles missing profiles.
          debugPrint(
              'Profile setup skipped after $attempt retries. '
              'Will complete on next login.');
        }
      } catch (error, stackTrace) {
        debugPrint('registerWithEmail profile setup failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        // Don't rethrow — the Firebase Auth account was created successfully.
        return;
      }
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
      if (map?['isBlocked'] == true) {
        // Stay signed in so the blocked user can still submit an unblock
        // appeal (Firestore rules require request.auth != null and
        // userId == request.auth.uid). Sign-out happens when the appeal
        // dialog closes — see BlockedUserDialog.
        throw BlockedUserException(
          userId: uid,
          userEmail: email,
        );
      }
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

class BlockedUserException implements Exception {
  const BlockedUserException({required this.userId, required this.userEmail});
  final String userId;
  final String userEmail;
}

