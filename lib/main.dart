import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/app.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthBinding().dependencies();
  runApp(const KaireteApp());
}
