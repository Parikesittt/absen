import 'package:absen/core/config/app_router.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/features/auth/data/auth_repository.dart';
import 'package:absen/features/auth/data/models/login_request.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_button.dart';
import 'widgets/input_field.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  bool hidePassword = true;

  final authRepo = AuthRepository();

  void submit() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    final request = LoginRequest(email: emailC.text, password: passwordC.text);

    try {
      final result = await authRepo.loginUser(request: request);
      PrefsService.saveToken(result.data?.token ?? "");
      if (context.mounted) {
        context.router.replacePath('/dashboard');
      }
    } catch (e) {
      print("ERROR LOGIN: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text("Masuk", style: Theme.of(context).textTheme.headlineMedium),

            const SizedBox(height: 40),

            RegisterInputField(
              hint: "Email",
              controller: emailC,
              obscureText: false,
            ),
            const SizedBox(height: 12),

            RegisterInputField(
              hint: "Password",
              controller: passwordC,
              obscureText: hidePassword,
              suffix: IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            AppButton(
              text: "Masuk",
              onPressed: () {
                submit();
                print("login clicked");
              },
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                print("Forgot password");
              },
              child: const Text("Lupa Password?"),
            ),
            TextButton(
              onPressed: () {
                context.pushRoute(const RegisterRoute());
              },
              child: const Text("Belum punya akun? Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}
