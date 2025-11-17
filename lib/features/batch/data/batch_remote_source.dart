import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/batch_model.dart';

class BatchRemoteSource {
  final api = HttpService();

  Future<BatchModel> getBatch() async {
    print("CALL API BATCH...");
    final json = await api.get(Endpoint.batches);
    print("RESPONSE BATCH: $json");
    return BatchModel.fromJson(json);
  }
}
