import 'package:flutter/material.dart';
import 'prefs_service.dart';

class AuthManager {
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Inisialisasi sekali di main()
  static void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// Dipanggil saat terdeteksi UnauthorizedException
  /// membersihkan prefs, dan pindah ke route login
  static Future<void> handleUnauthorized({String loginRoute = '/login'}) async {
    // clear saved token/user
    await PrefsService.clear();

    // navigate to login (replace everything)
    if (navigatorKey != null && navigatorKey!.currentState != null) {
      try {
        navigatorKey!.currentState!.pushNamedAndRemoveUntil(loginRoute, (route) => false);
      } catch (e) {
        debugPrint('AuthManager navigation error: $e');
      }
    }
  }
}
