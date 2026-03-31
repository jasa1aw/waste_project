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
        message: 'Не удалось получить UID после регистрации.',
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
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await credential.user?.getIdToken(true);
      await _upsertUserProfile(user);
      await _leaderboardService.ensureUserEntry(
        userId: user.id,
        displayName: user.name,
      );
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
      return 'Пользователь';
    }

    return local.length >= 2 ? local : 'Пользователь';
  }
}
