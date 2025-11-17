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

  final api = HttpService();
  Future<BatchModel> getAllBatch() async {
    final json = await api.get(Endpoint.batches);
    return BatchModel.fromJson(json);
  }
}
