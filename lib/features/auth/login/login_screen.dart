import 'dart:convert';

import 'package:absen/core/config/app_router.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/user_model.dart';
import 'package:absen/features/auth/data/auth_repository.dart';
import 'package:absen/features/auth/data/models/login_request.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool _isLoading = false;

  final authRepo = AuthRepository();

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    // basic validation
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    setState(() => _isLoading = true);

    final request = LoginRequest(
      email: emailC.text.trim(),
      password: passwordC.text,
    );

    try {
      final result = await authRepo.loginUser(request: request);

      // Ambil token
      final token = result.data?.token ?? '';
      if (token.isEmpty) {
        throw Exception('Token tidak ditemukan di response');
      }
      await PrefsService.saveToken(token);

      // Ambil user payload - bisa berupa Map atau object
      final dynamic userRaw = result.data?.user;

      Map<String, dynamic>? userMap;

      if (userRaw == null) {
        // no user returned
        debugPrint('Login: user field is null');
      } else if (userRaw is Map<String, dynamic>) {
        userMap = userRaw;
      } else {
        // try to convert using toJson or via encode/decode
        try {
          if ((userRaw as dynamic).toJson != null) {
            // If object has toJson method
            userMap = (userRaw as dynamic).toJson() as Map<String, dynamic>;
          } else {
            // Fallback: try json encode-decode
            final encoded = jsonEncode(userRaw);
            userMap = jsonDecode(encoded) as Map<String, dynamic>;
          }
        } catch (e) {
          debugPrint('Failed to normalize user payload: $e');
        }
      }

      if (userMap != null) {
        // create UserModel then save
        final userModel = UserModel.fromJson(userMap);
        await PrefsService.saveUserJson(userModel);
      }

      if (!mounted) return;
      // navigate to main/dashboard
      // gunakan router yang lo pakai; replace agar user tidak bisa back ke login
      context.router.replacePath('/main');
    } catch (e, st) {
      debugPrint('ERROR LOGIN: $e');
      debugPrintStack(stackTrace: st);

      String msg = 'Gagal login. Coba lagi.'; // default

      try {
        final raw = e.toString();

        // 1) Jika exception punya field message yang sudah JSON (contoh ApiException.message)
        //    some libs store JSON string inside e.message; cek dulu:
        if (e is ApiException) {
          final candidate = (e.message ?? '').toString();
          if (candidate.isNotEmpty) {
            // coba extract JSON dari candidate
            final jsonStart = candidate.indexOf('{');
            if (jsonStart != -1) {
              final jsonStr = candidate.substring(jsonStart);
              final parsed = jsonDecode(jsonStr);
              if (parsed is Map && parsed['message'] != null) {
                msg = parsed['message'].toString();
              } else {
                // fallback ke whole candidate (clean)
                msg = candidate;
              }
            } else {
              // tidak ada JSON, ambil substring setelah ":" terakhir
              final parts = candidate.split(':');
              msg = parts.isNotEmpty ? parts.last.trim() : candidate;
            }
          }
        }

        // 2) Jika belum dapat, coba cari JSON di seluruh e.toString()
        if (msg == 'Gagal login. Coba lagi.') {
          final s = e.toString();
          final jsonStart = s.indexOf('{');
          if (jsonStart != -1) {
            final jsonStr = s.substring(jsonStart);
            final parsed = jsonDecode(jsonStr);
            if (parsed is Map && parsed['message'] != null) {
              msg = parsed['message'].toString();
            } else {
              // kalau parsed tapi gak ada message, gunakan trimmed jsonStr (optional)
              msg = parsed.toString();
            }
          } else {
            // 3) fallback: ambil text setelah ":" terakhir
            final parts = s.split(':');
            if (parts.length > 1) {
              msg = parts.last.trim();
            } else {
              msg = s;
            }
          }
        }
      } catch (errParsing) {
        // kalau parsing JSON error, biarkan msg default atau gunakan string exception
        debugPrint('Failed to parse error message: $errParsing');
        msg = e.toString().replaceAll('Exception: ', '');
      }

      if (mounted) {
        // tampilkan ke user (boleh ganti ke SnackBar jika mau)
        Fluttertoast.showToast(msg: msg);
        // atau
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              text: _isLoading ? "Loading..." : "Masuk",
              onPressed: submit,
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                // TODO: forgot password flow
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
