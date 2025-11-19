import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/attendance_model.dart';
import 'package:absen/data/models/presence_history_model.dart';
import 'package:absen/data/models/presence_stats.dart';
import 'package:intl/intl.dart';

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
    final token = await PrefsService.getToken();
    final day = DateFormat('yyyy-MM-dd').format(date);

    // kalau endpoint memerlukan query param, sesuaikan.
    // Contoh: /absen/today?date=2025-11-17
    final endpoint = '${Endpoint.todayPresence}?date=$day';

    final json = await _api.get(
      endpoint,
      headers: {'Authorization': 'Bearer $token'},
    );

    // if (json == null) return null;
    final dynamic data = json['data'];

    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // langsung parse object
      try {
        return Presence.fromJson(data);
      } catch (e) {
        // parsing gagal -> return null
        return null;
      }
    } else if (data is List) {
      if (data.isEmpty) return null;
      final first = data.first;
      if (first is Map<String, dynamic>) {
        try {
          return Presence.fromJson(first);
        } catch (e) {
          return null;
        }
      }
      return null;
    } else {
      // unexpected shape
      return null;
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

  Future<Presence> izin({required Map<String, dynamic> body}) async {
    try {
      final json = await _api.post(Endpoint.izin, body);
      return Presence.fromJson(json);
    } on Exception {
      rethrow;
    }
  }
}
