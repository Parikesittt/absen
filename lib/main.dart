import 'package:absen/core/config/app_router.dart';
import 'package:absen/core/providers/theme_provider.dart';
import 'package:absen/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:provider/provider.dart';

void main() {
  runApp(
    rp.ProviderScope(                     // <= WAJIB ADA UNTUK RIVERPOD
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Absen App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _appRouter.config(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
