import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/training_model.dart';

class TrainingRemoteSource {
  final api = HttpService();

  Future<TrainingModel> getTraining() async {
    print("CALL API TRAINING...");
    final json = await api.get(Endpoint.trainings);
    print("RESPONSE TRAINING: $json");
    return TrainingModel.fromJson(json);
  }
}
