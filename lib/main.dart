import 'package:flutter/material.dart';
import 'package:kairete/app.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

/// Guest-preview diagnostic build.
///
/// Firebase and notifications are intentionally not initialized: an exception
/// from either native service must never prevent the first Flutter frame.
/// This build is for navigation/public-content testing only.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppBranding.initFromEnvironment();
  try {
    await AppBranding.ensureFromPackage();
  } catch (error) {
    debugPrint('Non-fatal branding initialization error: ${error.runtimeType}');
  }
  AppTheme.applyBranding(AppBranding.current);
  AppApi.instance.xenforo.syncAppIdentity();
  AuthBinding().dependencies();
  runApp(const KaireteApp());
}
