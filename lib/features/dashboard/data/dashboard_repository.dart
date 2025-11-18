import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/attendance_model.dart';
import 'package:absen/data/models/presence_history_model.dart';
import 'package:absen/data/models/presence_stats.dart';

class DashboardRepository {
  final HttpService _api = HttpService();

  /// Ambil riwayat absensi
  Future<PresenceHistoryModel> getPresenceHistory() async {
    try {
      final json = await _api.get(Endpoint.historyAbsen);
      // _api.get sudah meng-attach token otomatis (via PrefsService.getToken)
      return PresenceHistoryModel.fromJson(json);
    } on Exception {
      rethrow;
    }
  }

  /// contoh check-in (sesuaikan body / endpoint)
  Future<Map<String, dynamic>> checkIn({
    required double lat,
    required double lng,
    String? address,
  }) async {
    final body = {
      'lat': lat,
      'lng': lng,
      if (address != null) 'address': address,
    };

    try {
      final json = await _api.post(Endpoint.checkIn, body);
      return json;
    } on Exception {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkOut({
    required double lat,
    required double lng,
    String? address,
  }) async {
    final body = {
      'lat': lat,
      'lng': lng,
      if (address != null) 'address': address,
    };

    try {
      final json = await _api.post(Endpoint.checkOut, body);
      return json;
    } on Exception {
      rethrow;
    }
  }

  Future<Presence?> getTodayPresence(DateTime date) async {
    try {
      final yyyy = date.year.toString().padLeft(4, '0');
      final mm = date.month.toString().padLeft(2, '0');
      final dd = date.day.toString().padLeft(2, '0');
      final dateStr = '$yyyy-$mm-$dd';

      // Kita panggil endpoint with query param "date"
      // Endpoint.historyAbsen mis. '/absen/history' => jadi jadi '/absen/history?date=2025-11-17'
      final endpointWithQuery = '${Endpoint.todayPresence}?date=$dateStr';

      final json = await _api.get(endpointWithQuery);
      final model = PresenceHistoryModel.fromJson(json);
      if (model.data.isNotEmpty) {
        return model.data.first;
      }
      return null;
    } on Exception {
      rethrow;
    }
  }

  Future<PresenceStats> getPresenceStats() async {
    try {
      final json = await _api.get(
        Endpoint.presenceStats,
      ); // ganti konstanta ini sesuai Endpoint di project
      return PresenceStats.fromJson(json);
    } on Exception {
      rethrow;
    }
  }
}
