import 'package:absen/core/constant/endpoint.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/profile_model.dart';
import 'package:absen/features/profile/data/models/edit_profile_response.dart';

class ProfileRepository {
  final HttpService _api = HttpService();

  Future<ProfileModel> getProfile() async {
    final token = await PrefsService.getToken();
    try {
      final json = await _api.get(
        Endpoint.profile,
        headers: {'Authorization': 'Bearer $token'},
      );
      return ProfileModel.fromJson(json);
    } on Exception {
      rethrow;
    }
  }

  Future<EditProfileResponseModel> updateProfile({
    required String name,
    String? profilePhotoBase64,
  }) async {
    final token = await PrefsService.getToken(); // ambil token dari storage
    final body = {'name': name};
    final bodyPhoto = {'profile_photo': profilePhotoBase64};

    try {
      final requestProfile = await _api.put(
        Endpoint.profile,
        body,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (profilePhotoBase64 != null) {
        final requestProfilePhoto = await _api.put(
          Endpoint.updateProfilePhoto,
          bodyPhoto,
          headers: {'Authorization': 'Bearer $token'},
        );
        return EditProfileResponseModel.fromJson(requestProfilePhoto);
      }
      return EditProfileResponseModel.fromJson(requestProfile);
    } on Exception {
      rethrow;
    }
  }
}
