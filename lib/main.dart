import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/app.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppBranding.initFromEnvironment();
  await AppBranding.ensureFromPackage();
  AppTheme.applyBranding(AppBranding.current);
  AppApi.instance.xenforo.syncAppIdentity();
  AuthBinding().dependencies();
  runApp(const KaireteApp());
}
