import 'package:absen/core/config/app_router.dart';
import 'package:absen/features/auth/data/auth_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final emailC = TextEditingController();
  bool loading = false;
  final authRepo = AuthRepository();

  Future<void> submit() async {
    if (emailC.text.isEmpty) return;

    setState(() => loading = true);

    try {
      /// TODO: panggil API kirim OTP
      /// contoh:
      await authRepo.sendOtp(emailC.text);

      if (!mounted) return;

      context.router.push(ForgotPasswordOtpRoute(email: emailC.text.trim()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengirim OTP: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lupa Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Masukkan email untuk menerima kode OTP."),
            const SizedBox(height: 20),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Kirim OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
