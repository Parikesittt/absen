import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/batch_model.dart';

class BatchRepository {
  // final BatchRemoteSource remote;

  // BatchRepository(this.remote);

  // Future<List<Datum>> getBatchList() async {
  //   final res = await remote.getBatch();
  //   return res.data ?? [];
  // }

  final HttpService _api = HttpService();
  Future<BatchModel> getAllBatch() async {
    try {
      final json = await _api.get(Endpoint.batches);
      return BatchModel.fromJson(json);
    } on Exception {
      rethrow;
    }
  }
}
