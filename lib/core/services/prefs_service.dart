import 'dart:convert';

import 'package:absen/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String tokenKey = 'token';
  static const String isLoginKey = 'isLogin';
  static const String userKey = 'user_json';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> saveLogin(bool isLogin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoginKey, isLogin);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoginKey);
  }

  static Future<void> saveUserJson(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(user.toJson());
    await prefs.setString(userKey, raw);
    debugPrint('PrefsService.saveUserModel saved: ${user.toJson()}');
  }

  static Future<UserModel?> getUserModel() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    debugPrint('PrefsService.getUserModel raw: $userJson');
    if (userJson != null) {
      final Map<String, dynamic> userMap =
          json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
