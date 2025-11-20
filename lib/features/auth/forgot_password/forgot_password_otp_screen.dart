import 'package:absen/core/config/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final otpC = TextEditingController();
  bool loading = false;

  Future<void> submitOtp() async {
    if (otpC.text.isEmpty) return;

    setState(() => loading = true);

    try {
      /// Ga usah verify API di sini kalau API lu cuma verify pas reset password.
      /// Jadi langsung ke halaman password.
      context.router.push(
        ResetPasswordRoute(
          email: widget.email,
          otp: otpC.text.trim(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP salah: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Kode OTP telah dikirim ke email:\n${widget.email}"),
            const SizedBox(height: 20),
            TextField(
              controller: otpC,
              decoration: const InputDecoration(
                labelText: "Kode OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submitOtp,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verifikasi"),
            ),
          ],
        ),
      ),
    );
  }
}
