import 'dart:convert';
import 'package:absen/core/config/api_config.dart';
import 'package:http/http.dart' as http;

class AuthRemoteSource {
  final baseUrl = ApiConfig.baseUrl;
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String photoBase64,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "gender": gender,
        "photo": photoBase64,
        "batch_id": batchId,
        "training_id": trainingId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Gagal register",
        "code": response.statusCode,
        "body": response.body,
      };
    }
  }
}
