import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/presence/app_presence_service.dart';
import 'package:kairete/core/push/push_background_handler.dart';
import 'package:kairete/core/push/push_navigation.dart';
import 'package:kairete/core/push/push_token_service.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final PushTokenService _tokenService = PushTokenService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'kairete_alerts',
    'Notifiche Kairete',
    description: 'Alert e aggiornamenti dal forum',
  );

  String? _currentToken;
  int? _registeredUserId;
  bool _initialized = false;
  bool _listenersBound = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        unawaited(_handlePayloadTap(payload));
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _initialized = true;
  }

  Future<bool> _ensureNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
      return granted;
    }

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> register({required int userId}) async {
    if (userId <= 0) return;
    await initialize();
    _bindListeners();

    final allowed = await _ensureNotificationPermission();
    if (!allowed) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    _registeredUserId = userId;
    _currentToken = token;

    await _tokenService.registerToken(userId: userId, token: token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final activeUserId = _registeredUserId ?? userId;
      if (activeUserId <= 0 || newToken.isEmpty) return;
      _currentToken = newToken;
      await _tokenService.registerToken(userId: activeUserId, token: newToken);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _handleRemoteMessage(initialMessage, fromTap: true);
    }
  }

  Future<void> unregister() async {
    final userId = _registeredUserId ?? await AppApi.instance.sessionUserId;
    final token = _currentToken;
    if (userId != null && userId > 0 && token != null && token.isNotEmpty) {
      await _tokenService.unregisterToken(userId: userId, token: token);
    }
    _registeredUserId = null;
    _currentToken = null;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  void _bindListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    FirebaseMessaging.onMessage.listen((message) async {
      await _handleRemoteMessage(message, fromTap: false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await _handleRemoteMessage(message, fromTap: true);
    });
  }

  Future<void> _handleRemoteMessage(
    RemoteMessage message, {
    required bool fromTap,
  }) async {
    if (fromTap) {
      await _openFromMessage(message);
      return;
    }

    _refreshAlertsBadge();

    if (AppPresenceService.instance.isForeground) {
      return;
    }

    final notification = message.notification;
    if (notification == null || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@drawable/ic_notification',
          color: AppTheme.brandPrimary,
        ),
      ),
      payload: _payloadFromMessage(message),
    );
  }

  Future<void> _openFromMessage(RemoteMessage message) async {
    final data = message.data;
    if (data.isNotEmpty) {
      final opened = await PushNavigation.openFromData(data);
      if (opened) return;
    }
    final payload = _payloadFromMessage(message);
    if (payload != null) {
      await _handlePayloadTap(payload);
    }
  }

  Future<void> _handlePayloadTap(String payload) async {
    final parts = payload.split('|');
    if (parts.length != 2) return;
    await PushNavigation.openFromData({
      'content_type': parts[0],
      'content_id': parts[1],
    });
  }

  String? _payloadFromMessage(RemoteMessage message) {
    final type = message.data['content_type']?.toString();
    final id = message.data['content_id']?.toString();
    if (type == null || id == null || type.isEmpty || id.isEmpty) {
      return null;
    }
    return '$type|$id';
  }

  void _refreshAlertsBadge() {
    if (Get.isRegistered<AlertsBadgeController>()) {
      unawaited(Get.find<AlertsBadgeController>().refresh());
    }
  }
}
