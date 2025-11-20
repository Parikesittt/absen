import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/auth_model.dart';
import 'package:absen/features/auth/data/models/login_request.dart';
import 'package:absen/features/auth/data/models/register_request.dart';

class AuthRepository {
  final HttpService _api = HttpService();

  /// Register user
  Future<AuthModel> registerUser({required RegisterRequest request}) async {
    try {
      final json = await _api.post(Endpoint.register, request.toJson());
      return AuthModel.fromJson(json);
    } on Exception catch (e) {
      // biarkan caller menangani spesifik exception
      rethrow;
    }
  }

  /// Login user
  Future<AuthModel> loginUser({required LoginRequest request}) async {
    try {
      final json = await _api.post(Endpoint.login, request.toJson());
      return AuthModel.fromJson(json);
    } on Exception {
      rethrow;
    }
  }

  Future<String> sendOtp(String email) async {
    try {
      final body = {'email': email};
      final json = await _api.post(Endpoint.sendOtp, body);
      // Jika API konsisten mengembalikan object dengan key 'message'
      final msg = (json['message'] ?? '') as String;
      return msg;
    } on Exception {
      // jika kamu punya ApiException, ubah di sini
      // contoh sederhana:
      rethrow;
      // throw ApiException(message: e.toString());
    }
  }

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final body = {'email': email, 'otp': otp, 'password': newPassword};
      final json = await _api.post(Endpoint.resetPass, body);
      final msg = (json['message'] ?? '') as String;
      return msg;
    } on Exception {
      rethrow;
      // throw ApiException(message: e.toString());
    }
  }
}
