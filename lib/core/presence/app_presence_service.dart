import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/session/device_session_store.dart';

/// Segnala foreground/background al server per sopprimere push ridondanti.
class AppPresenceService with WidgetsBindingObserver {
  AppPresenceService._();

  static final AppPresenceService instance = AppPresenceService._();

  static const Duration heartbeatInterval = Duration(seconds: 45);

  final XenforoApi _api = AppApi.instance.xenforo;

  bool _observerRegistered = false;
  bool _authenticated = false;
  bool _isForeground = true;
  Timer? _heartbeat;

  bool get isForeground => _isForeground;

  void ensureObserverRegistered() {
    if (_observerRegistered) return;
    WidgetsBinding.instance.addObserver(this);
    _observerRegistered = true;
    _isForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  void onUserAuthenticated() {
    _authenticated = true;
    ensureObserverRegistered();
    unawaited(_sendPresence(_isForeground ? 'foreground' : 'background'));
    _syncHeartbeat();
  }

  Future<void> onUserLoggedOut() async {
    _authenticated = false;
    _stopHeartbeat();
    if (_observerRegistered) {
      await _sendPresence('background');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isForeground = true;
        if (_authenticated) {
          unawaited(_sendPresence('foreground'));
          _startHeartbeat();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isForeground = false;
        if (_authenticated) {
          unawaited(_sendPresence('background'));
          _stopHeartbeat();
        }
        break;
    }
  }

  void _syncHeartbeat() {
    if (_authenticated && _isForeground) {
      _startHeartbeat();
    } else {
      _stopHeartbeat();
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(heartbeatInterval, (_) {
      if (_authenticated && _isForeground) {
        unawaited(_sendPresence('foreground'));
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  Future<void> _sendPresence(String appState) async {
    final userId = await AppApi.instance.sessionUserId;
    if (userId == null || userId <= 0) return;

    try {
      final deviceKey =
          await DeviceSessionStore.instance.getOrCreateDeviceKey();
      await _api.post(
        ApiPaths.mobileDevicePresence,
        body: {
          'device_key': deviceKey,
          'app_id': AppConfig.mobileAppId,
          'app_state': appState,
        },
      );
    } catch (_) {
      // Presenza best-effort: non bloccare l'app.
    }
  }
}
