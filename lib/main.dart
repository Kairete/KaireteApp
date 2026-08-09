import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kairete/app.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/presence/app_presence_service.dart';
import 'package:kairete/core/push/push_notification_service.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppBranding.initFromEnvironment();
  await AppBranding.ensureFromPackage();
  AppTheme.applyBranding(AppBranding.current);
  AppApi.instance.xenforo.syncAppIdentity();
  await Firebase.initializeApp();
  await PushNotificationService.instance.initialize();
  AppPresenceService.instance.ensureObserverRegistered();
  AuthBinding().dependencies();
  runApp(const KaireteApp());
}
