import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/presence_history_model.dart';

class DashboardRepository {
  final api = HttpService();

  Future<PresenceHistoryModel> getPresenceHistory() async {
    final token = await PrefsService.getToken(); // ambil token dari storage
    print(token);

    final json = await api.get(
      Endpoint.historyAbsen,
      headers: {'Authorization': 'Bearer $token'},
    );
    return PresenceHistoryModel.fromJson(json);
  }
}
