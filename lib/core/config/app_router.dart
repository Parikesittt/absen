import 'package:auto_route/auto_route.dart';
import 'package:absen/features/auth/register/register_screen.dart';
import 'package:absen/features/auth/login/login_screen.dart';
import 'package:absen/features/dashboard/dashboard_screen.dart';
import 'package:absen/features/attendance/attendance_screen.dart';
import 'package:absen/features/profile/profile_screen.dart';
import 'package:absen/features/profile/edit_profile_screen.dart';
import 'package:absen/features/history/history_screen.dart';
import 'package:absen/ui/shell/main_scaffold.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MainScaffoldRoute.page, path: '/main'),
    AutoRoute(page: DashboardRoute.page, path: '/dashboard'),
    AutoRoute(page: ProfileRoute.page, path: '/profile'),
    AutoRoute(page: EditProfileRoute.page, path: '/profile/edit'),
    AutoRoute(page: LoginRoute.page, initial: true, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(page: AttendanceRoute.page, path: '/attendance'),
    AutoRoute(page: HistoryRoute.page, path: '/history'),
  ];
}
