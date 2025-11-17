import 'dart:convert';
import 'dart:io';
import 'package:absen/core/constant/spacing.dart';
import 'package:absen/features/auth/data/auth_repository.dart';
import 'package:absen/features/auth/data/models/register_request.dart';
import 'package:absen/features/batch/data/batch_repository.dart';
import 'package:absen/data/models/batch_model.dart';
import 'package:absen/data/models/training_model.dart';
import 'package:absen/features/training/data/training_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'widgets/profile_upload_widget.dart';
import 'widgets/gender_selector.dart';
import 'widgets/input_field.dart';
import '../../../shared/widgets/app_button.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  dynamic selectedBatch;
  dynamic selectedTraining;
  Future<void>? loadDropdownFuture;
  late Future<List<Trainings>> trainingListFuture;
  late Future<List<Batch>> batchListFuture;

  String? selectedGender;
  String? base64Photo;

  final authRepo = AuthRepository();
  final trainingRepo = TrainingRepository();
  final batchRepo = BatchRepository();

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final bytes = await File(file.path).readAsBytes();
    setState(() {
      base64Photo = "data:image/png;base64,${base64Encode(bytes)}";
    });
  }

  void loadData() {
    final trainingFuture = trainingRepo.getAllTraining();
    trainingListFuture = trainingFuture.then((value) => value.data ?? []);
    final batchFuture = batchRepo.getAllBatch();
    batchListFuture = batchFuture.then((value) => value.data ?? []);
    setState(() {});
    // loadDropdownFuture = Future.wait([
    //   ref.read(batchProvider.notifier).fetchBatches(),
    //   ref.read(trainingProvider.notifier).fetchTrainings(),
    // ]);
  }

  void submit() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty || selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    final request = RegisterRequest(
      name: nameC.text,
      email: emailC.text,
      password: passwordC.text.isEmpty ? "Password123!" : passwordC.text,
      jenisKelamin: selectedGender!,
      profilePhoto: base64Photo!,
      batchId: 1,
      trainingId: 1,
    );

    try {
      final result = await authRepo.registerUser(request: request);
      // PrefsService.saveToken(result.data?.token ?? "");
      if (context.mounted) {
        context.router.replacePath('/login');
      }
    } catch (e) {
      print("ERROR REGISTER: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileUploadWidget(onTap: pickPhoto),

            const SizedBox(height: 20),

            RegisterInputField(
              hint: "Masukkan nama lengkap",
              controller: nameC,
            ),
            const SizedBox(height: 12),

            RegisterInputField(hint: "email@gmail.com", controller: emailC),
            const SizedBox(height: 12),

            RegisterInputField(
              hint: "Password",
              controller: passwordC,
              isPassword: true,
            ),
            const SizedBox(height: 12),

            GenderSelector(
              selected: selectedGender,
              onChanged: (value) {
                setState(() => selectedGender = value);
              },
            ),

            h(12),

            FutureBuilder<List<Trainings>>(
              future: trainingListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada data training');
                }

                return DropdownButtonFormField<Trainings>(
                  decoration: InputDecoration(
                    hintText: 'Pilih Training',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  isExpanded: true,
                  value: selectedTraining,
                  items: snapshot.data!.map((training) {
                    return DropdownMenuItem<Trainings>(
                      value: training,
                      child: Text(
                        training.title ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ), // sesuaikan dengan field di model
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTraining = value;
                    });
                  },
                );
              },
            ),

            h(12),

            FutureBuilder<List<Batch>>(
              future: batchListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada data training');
                }

                return DropdownButtonFormField<Batch>(
                  decoration: InputDecoration(
                    hintText: 'Pilih Batch',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  isExpanded: true,
                  value: selectedBatch,
                  items: snapshot.data!.map((batch) {
                    return DropdownMenuItem<Batch>(
                      value: batch,
                      child: Text(
                        batch.batchKe ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ), // sesuaikan dengan field di model
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBatch = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            AppButton(text: "Daftar Sekarang", onPressed: submit),
          ],
        ),
      ),
    );
  }
}
