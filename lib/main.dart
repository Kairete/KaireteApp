import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/app.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppBranding.initFromEnvironment();
  AppTheme.applyBranding(AppBranding.current);
  AuthBinding().dependencies();
  runApp(const KaireteApp());
}
