import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/auth_model.dart';
import 'package:absen/features/auth/data/models/login_request.dart';
import 'package:absen/features/auth/data/models/register_request.dart';

import 'auth_remote_source.dart';

// class AuthRepository {
//   final AuthRemoteSource remote;

//   AuthRepository(this.remote);

//   Future<Map<String, dynamic>> register({
//     required String name,
//     required String email,
//     required String password,
//     required String gender,
//     required String photoBase64,
//     required int batchId,
//     required int trainingId,
//   }) async {
//     return await remote.register(
//       name: name,
//       email: email,
//       password: password,
//       gender: gender,
//       photoBase64: photoBase64,
//       batchId: batchId,
//       trainingId: trainingId,
//     );
//   }
// }

class AuthRepository {
  final api = HttpService();

  Future<AuthModel> registerUser({required RegisterRequest request}) async {
    final json = await api.post(Endpoint.register, request.toJson());

    return AuthModel.fromJson(json);
  }

  Future<AuthModel> loginUser({required LoginRequest request}) async {
    final json = await api.post(Endpoint.login, request.toJson());

    return AuthModel.fromJson(json);
  }
}
