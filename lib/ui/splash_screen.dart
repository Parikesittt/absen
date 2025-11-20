import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/shared/widgets/app_footer.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:absen/core/config/app_router.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3)).then((_) async {
      var isLogin = await PrefsService.getLogin();
      debugPrint("isLogin: $isLogin");

      if (!mounted) return; // mastiin widget masih aktif

      if (isLogin != null && isLogin == true) {
        context.router.replace(const MainScaffoldRoute());
      } else {
        context.router.replace(const LoginRoute());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Navy dark tech
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOGO
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  "assets/images/logo.png", // tempatkan logo AttendifyX kamu
                  width: 110,
                  height: 110,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "AttendifyX",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Modern Attendance System",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
