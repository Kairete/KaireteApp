import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/auth/models/user_account.dart';
import 'package:kairete/features/auth/pages/login_page.dart';
import 'package:kairete/features/auth/services/auth_service.dart';
import 'package:kairete/features/home/bindings/home_binding.dart';
import 'package:kairete/features/home/pages/home_shell_page.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';

class AuthFlowController extends GetxController {
  final AuthService _auth = AuthService();

  final isLoading = false.obs;
  final isRestoringSession = false.obs;
  final errorMessage = ''.obs;
  final currentUser = Rxn<UserAccount>();

  /// All'avvio: prova sessione salvata (max 8s), altrimenti resta su login.
  Future<void> tryRestoreSession() async {
    isRestoringSession.value = true;
    errorMessage.value = '';
    try {
      final user = await _auth.restoreSession().timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
      if (user != null) {
        currentUser.value = user;
        AppApi.instance.bindSession(user.userId);
        isRestoringSession.value = false;
        _goAfterAuth(user);
        return;
      }
    } catch (_) {
      await _auth.logout();
    } finally {
      isRestoringSession.value = false;
    }
  }

  Future<void> bootstrap() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _auth.restoreSession().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('timeout'),
      );
      if (user == null) {
        _openLogin();
        return;
      }
      currentUser.value = user;
      AppApi.instance.bindSession(user.userId);
      isLoading.value = false;
      _goAfterAuth(user);
      return;
    } on TimeoutException {
      await _auth.logout();
      _openLogin(
        message: 'Connessione lenta. Accedi di nuovo.',
      );
    } catch (_) {
      await _auth.logout();
      _openLogin();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> skipToLogin() async {
    await _auth.logout();
    _openLogin();
  }

  void _openLogin({String? message}) {
    if (message != null) errorMessage.value = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = Get.key.currentState;
      if (nav == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.login),
          builder: (_) => const LoginPage(),
        ),
        (_) => false,
      );
    });
  }

  Future<void> login(String login, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _auth.login(login: login, password: password);
      currentUser.value = user;
      AppApi.instance.bindSession(user.userId);
      isLoading.value = false;
      _goAfterAuth(user);
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Errore di connessione. Riprova.';
    } finally {
      if (Get.currentRoute == AppRoutes.login) {
        isLoading.value = false;
      }
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required DateTime dob,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _auth.register(
        username: username,
        email: email,
        password: password,
        dateOfBirth: dob,
      );
      currentUser.value = user;
      AppApi.instance.bindSession(user.userId);
      isLoading.value = false;
      _goAfterAuth(user);
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Errore di connessione. Riprova.';
    } finally {
      if (Get.currentRoute == AppRoutes.register) {
        isLoading.value = false;
      }
    }
  }

  Future<void> saveProfileFields(Map<String, String> fields) async {
    final user = currentUser.value;
    if (user == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final updated = await _auth.updateProfile(
        userId: user.userId,
        customFields: fields,
      );
      currentUser.value = updated;
      isLoading.value = false;
      _goHome();
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Salvataggio non riuscito.';
    } finally {
      if (Get.currentRoute == AppRoutes.profileFields) {
        isLoading.value = false;
      }
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    currentUser.value = null;
    if (Get.isRegistered<OmnifeedController>()) {
      Get.delete<OmnifeedController>(force: true);
    }
    if (Get.isRegistered<AlertsBadgeController>()) {
      Get.delete<AlertsBadgeController>(force: true);
    }
    _openLogin();
  }

  /// Salta nome/cognome e apre la home con binding feed già pronto.
  void skipProfileFields() {
    final user = currentUser.value;
    if (user != null) {
      AppApi.instance.bindSession(user.userId);
    }
    isLoading.value = false;
    _openHomeAfterBootstrap();
  }

  void _goAfterAuth(UserAccount user) {
    if (user.needsProfileFields) {
      _navigateTo(AppRoutes.profileFields);
    } else {
      _openHomeAfterBootstrap();
    }
  }

  Future<void> _openHomeAfterBootstrap() async {
    if (AppConfig.isTenantApp) {
      isLoading.value = true;
      try {
        await TenantService().ensureTenantReady();
      } catch (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
        return;
      }
      isLoading.value = false;
    }
    _openHome();
  }

  void _goHome() => _openHome();

  /// Navigazione Flutter pura: evita overlay GetX che bloccano i tap.
  void _openHome() {
    HomeBinding().dependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = Get.key.currentState;
      if (nav == null) {
        Get.offAllNamed(AppRoutes.home);
        return;
      }
      nav.pushAndRemoveUntil(
        PageRouteBuilder<void>(
          settings: const RouteSettings(name: AppRoutes.home),
          pageBuilder: (_, __, ___) => const HomeShellPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (_) => false,
      );
    });
  }

  void _navigateTo(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(route);
    });
  }
}
