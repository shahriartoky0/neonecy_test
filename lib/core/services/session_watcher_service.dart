import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../config/app_constants.dart';
import '../config/app_url.dart';
import '../network/network_caller.dart';
import '../network/network_response.dart';
import '../routes/app_routes.dart';
import '../utils/get_storage.dart';
import '../utils/logger_utils.dart';

/// Silently re-validates the saved session against `GET /api/user` at least
/// once every 24 hours - checked on app launch, on app resume, and on a
/// periodic timer while the app stays in the foreground.
///
/// If that call comes back unauthorized, or the account's `status` is no
/// longer "approved", the user is signed out with no dialog or toast.
/// Network failures (no connectivity, timeouts, server errors) are ignored
/// so a flaky connection never forces a logout.
class SessionWatcherService extends GetxService with WidgetsBindingObserver {
  static const Duration sessionValidityWindow = Duration(hours: 24);
  static const Duration _pollInterval = Duration(minutes: 30);

  Timer? _timer;
  bool _isChecking = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_pollInterval, (_) => _checkSessionIfDue());
    // Give the app a moment to finish booting before the first check.
    Future<void>.delayed(const Duration(seconds: 3), _checkSessionIfDue);
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSessionIfDue();
    }
  }

  Future<void> _checkSessionIfDue() async {
    if (_isChecking) {
      return;
    }
    final String? token = GetStorageModel().read(AppConstants.token) as String?;
    if (token == null || token.isEmpty) {
      return;
    }

    final String? lastLoginAtRaw = GetStorageModel().read(AppConstants.lastLoginAt) as String?;
    final DateTime? lastLoginAt =
        lastLoginAtRaw != null ? DateTime.tryParse(lastLoginAtRaw) : null;
    if (lastLoginAt != null && DateTime.now().difference(lastLoginAt) < sessionValidityWindow) {
      return;
    }

    _isChecking = true;
    try {
      await _revalidateSession(token);
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _revalidateSession(String token) async {
    try {
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.currentUser,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        /// Token rejected outright - sign the user out quietly.
        await _forceLogout();
        return;
      }

      if (!response.isSuccess || response.jsonResponse == null) {
        /// Anything else (no connectivity, timeout, 5xx) is treated as
        /// transient - don't punish the user, just retry on the next check.
        return;
      }

      final String? status = response.jsonResponse?['status']?.toString();
      if (status == 'approved') {
        await GetStorageModel().save(
          AppConstants.lastLoginAt,
          response.jsonResponse?['last_login_at']?.toString() ?? DateTime.now().toIso8601String(),
        );
        return;
      }

      /// Account is no longer approved - sign the user out quietly.
      await _forceLogout();
    } catch (e) {
      LoggerUtils.error('Session revalidation failed: $e');
    }
  }

  Future<void> _forceLogout() async {
    await GetStorageModel().delete(AppConstants.token);
    await GetStorageModel().delete(AppConstants.lastLoginAt);
    if (Get.currentRoute != AppRoutes.loginScreen) {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}
