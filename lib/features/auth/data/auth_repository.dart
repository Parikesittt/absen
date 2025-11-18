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
}
