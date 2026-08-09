import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToast {
  static void info(String title, String message) => _show(title, message);

  static void error(String message) => _show('Errore', message);

  static void success(String message) => _show('Ok', message);

  static void _show(String title, String message) {
    if (Get.isSnackbarOpen == true) {
      Get.closeAllSnackbars();
    }
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
    );
  }

  static String mapApiError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('login_required') || lower.contains('logged-in')) {
      return 'Accedi per continuare.';
    }
    if (lower.contains('endpoint_not_found') ||
        lower.contains('invalid_route') ||
        lower.contains('cannot be found')) {
      return 'Endpoint non disponibile sul server. Aggiorna OmniFeed.';
    }
    if (lower.contains('permission') || lower.contains('permess')) {
      return 'Non hai i permessi necessari per questa azione.';
    }
    if (lower.contains('own content') ||
        lower.contains('cheating') ||
        lower.contains('tuoi contenuti')) {
      return 'Non puoi reagire ai tuoi contenuti.';
    }
    if (lower.contains('server_error') ||
        lower.contains('unexpected_error')) {
      return 'Errore sul server. Riprova tra poco.';
    }
    return message;
  }
}
