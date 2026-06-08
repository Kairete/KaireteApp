import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/app.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) {
    return Material(
      color: const Color(0xFFFFEBEE),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Errore UI:\n${details.exceptionAsString()}',
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
      ),
    );
  };
  AuthBinding().dependencies();
  runApp(const KaireteApp());
}
