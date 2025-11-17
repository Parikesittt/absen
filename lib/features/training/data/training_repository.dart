import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/training_model.dart';


class TrainingRepository {
  // final TrainingRemoteSource remote;

  // TrainingRepository(this.remote);

  // Future<Training> getTrainingList() async {
  //   final res = await remote.getTraining();
  //   return res.data ?? [];
  // }
  final api = HttpService();
  Future<TrainingModel> getAllTraining() async {
    final json = await api.get(Endpoint.trainings);
    return TrainingModel.fromJson(json);
  }
}
