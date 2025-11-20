class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String jenisKelamin;
  final String? profilePhoto;
  final int batchId;
  final int trainingId;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.jenisKelamin,
    this.profilePhoto,
    required this.batchId,
    required this.trainingId,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "password": password,
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto ?? '',
    "batch_id": batchId.toString(),
    "training_id": trainingId.toString(),
  };
}
