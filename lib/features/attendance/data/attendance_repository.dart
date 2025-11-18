import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/attendance_model.dart';
import 'package:absen/features/attendance/data/models/attendance_request.dart';

class AttendanceRepository {
  final HttpService _api = HttpService();

  Future<AttendanceModel> checkIn({required AttendanceRequest request}) async {
    final token = await PrefsService.getToken(); // ambil token dari storage
    // print(token);
    try {
      final json = await _api.post(
        Endpoint.checkIn,
        request.toJson(),
        headers: {'Authorization': 'Bearer $token'},
      );
      return AttendanceModel.fromJson(json);
    } on Exception {
      rethrow;
    }
  }

  Future<AttendanceModel> checkOut({required AttendanceRequest request}) async {
    final token = await PrefsService.getToken(); // ambil token dari storage
    // print(token);
    try {
      final json = await _api.post(
        Endpoint.checkOut,
        request.toJson(),
        headers: {'Authorization': 'Bearer $token'},
        
      );
      return AttendanceModel.fromJson(json);
    } on Exception {
      rethrow;
    }
  }
}
