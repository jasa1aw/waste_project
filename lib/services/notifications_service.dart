import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsService {
  NotificationsService._();

  static final NotificationsService instance = NotificationsService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  Future<void>? _pendingTopicSync;
  bool? _pendingTopicEnabledState;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    _initialized = true;

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else {
      await _messaging.requestPermission();
    }

    final prefs = await SharedPreferences.getInstance();
    final remindersEnabled = prefs.getBool('sorting_reminders_enabled') ?? true;
    await _syncTopicSubscription(remindersEnabled);
    await _saveTokenForCurrentUser();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) async {
      await _saveTokenForCurrentUser();
    });

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((_) async {
      await _saveTokenForCurrentUser();
    });
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    await _syncTopicSubscription(enabled);
  }

  Future<void> _syncTopicSubscription(bool enabled) async {
    if (await _canManageTopicsNow()) {
      try {
        await _applyTopicSubscription(enabled);
      } catch (error) {
        if (!_isApnsTokenNotReadyError(error)) {
          rethrow;
        }

        _pendingTopicEnabledState = enabled;
        _pendingTopicSync ??= _retryPendingTopicSubscription();
      }
      return;
    }

    // APNS token can arrive slightly after startup on iOS; retry in background.
    _pendingTopicEnabledState = enabled;
    _pendingTopicSync ??= _retryPendingTopicSubscription();
  }

  bool _isApnsTokenNotReadyError(Object error) {
    return error.toString().contains('apns-token-not-set');
  }

  Future<bool> _canManageTopicsNow() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return true;
    }

    final apnsToken = await _messaging.getAPNSToken();
    return apnsToken != null && apnsToken.isNotEmpty;
  }

  Future<void> _applyTopicSubscription(bool enabled) async {
    if (enabled) {
      await _messaging.subscribeToTopic('sorting-reminders');
    } else {
      await _messaging.unsubscribeFromTopic('sorting-reminders');
    }
  }

  Future<void> _retryPendingTopicSubscription() async {
    try {
      for (var attempt = 0; attempt < 12; attempt++) {
        await Future<void>.delayed(const Duration(seconds: 2));

        final pendingState = _pendingTopicEnabledState;
        if (pendingState == null) {
          return;
        }

        if (await _canManageTopicsNow()) {
          await _applyTopicSubscription(pendingState);
          _pendingTopicEnabledState = null;
          return;
        }
      }
    } finally {
      _pendingTopicSync = null;
    }
  }

  Future<void> _saveTokenForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      if (!await _canManageTopicsNow()) {
        _scheduleTokenSaveRetry();
        return;
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'notificationsEnabled': true,
        'lastActiveAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (_isApnsTokenNotReadyError(e)) {
        _scheduleTokenSaveRetry();
        return;
      }
      debugPrint('Error getting or saving token: $e');
    }
  }

  bool _isRetryScheduled = false;

  void _scheduleTokenSaveRetry() {
    if (_isRetryScheduled) return;
    _isRetryScheduled = true;
    
    Future.microtask(() async {
      try {
        for (var attempt = 0; attempt < 12; attempt++) {
          await Future<void>.delayed(const Duration(seconds: 2));
          if (await _canManageTopicsNow()) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;
            
            final token = await _messaging.getToken();
            if (token != null && token.isNotEmpty) {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'fcmToken': token,
                'notificationsEnabled': true,
                'lastActiveAt': DateTime.now().toIso8601String(),
              }, SetOptions(merge: true));
            }
            break;
          }
        }
      } catch (e) {
         if (!_isApnsTokenNotReadyError(e)) {
           debugPrint('Error during token retry: $e');
         }
      } finally {
        _isRetryScheduled = false;
      }
    });
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    _pendingTopicEnabledState = null;
  }
}
