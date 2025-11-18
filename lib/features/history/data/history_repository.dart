import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/features/history/data/models/delete_history_model.dart';

class HistoryRepository {
  final HttpService _api = HttpService();

  Future<DeleteHistoryModel> deleteHistory({required int id}) async {
    try {
      final json = await _api.delete('${Endpoint.deleteAbsen}/$id');
      return DeleteHistoryModel.fromJson(json);
    } on Exception {
      rethrow;
    }
  }
}
