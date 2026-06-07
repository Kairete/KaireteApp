import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/models/user_account.dart';
import 'package:kairete/features/auth/services/auth_service.dart';

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
        _goAfterAuth(user);
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
      _goAfterAuth(user);
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
    Future.microtask(() {
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  Future<void> login(String login, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _auth.login(login: login, password: password);
      currentUser.value = user;
      AppApi.instance.bindSession(user.userId);
      _goAfterAuth(user);
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Errore di connessione. Riprova.';
    } finally {
      isLoading.value = false;
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
      _goAfterAuth(user);
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Errore di connessione. Riprova.';
    } finally {
      isLoading.value = false;
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
      Get.offAllNamed(AppRoutes.home);
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Salvataggio non riuscito.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  void _goAfterAuth(UserAccount user) {
    if (user.needsProfileFields) {
      Get.offAllNamed(AppRoutes.profileFields);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
