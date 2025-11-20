// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AttendanceScreen]
class AttendanceRoute extends PageRouteInfo<AttendanceRouteArgs> {
  AttendanceRoute({
    Key? key,
    required String type,
    List<PageRouteInfo>? children,
  }) : super(
         AttendanceRoute.name,
         args: AttendanceRouteArgs(key: key, type: type),
         rawPathParams: {'type': type},
         initialChildren: children,
       );

  static const String name = 'AttendanceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AttendanceRouteArgs>(
        orElse: () => AttendanceRouteArgs(type: pathParams.getString('type')),
      );
      return AttendanceScreen(key: args.key, type: args.type);
    },
  );
}

class AttendanceRouteArgs {
  const AttendanceRouteArgs({this.key, required this.type});

  final Key? key;

  final String type;

  @override
  String toString() {
    return 'AttendanceRouteArgs{key: $key, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AttendanceRouteArgs) return false;
    return key == other.key && type == other.type;
  }

  @override
  int get hashCode => key.hashCode ^ type.hashCode;
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfileScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordEmailScreen]
class ForgotPasswordEmailRoute extends PageRouteInfo<void> {
  const ForgotPasswordEmailRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordEmailRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordEmailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordEmailScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordOtpScreen]
class ForgotPasswordOtpRoute extends PageRouteInfo<ForgotPasswordOtpRouteArgs> {
  ForgotPasswordOtpRoute({
    Key? key,
    required String email,
    List<PageRouteInfo>? children,
  }) : super(
         ForgotPasswordOtpRoute.name,
         args: ForgotPasswordOtpRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'ForgotPasswordOtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForgotPasswordOtpRouteArgs>();
      return ForgotPasswordOtpScreen(key: args.key, email: args.email);
    },
  );
}

class ForgotPasswordOtpRouteArgs {
  const ForgotPasswordOtpRouteArgs({this.key, required this.email});

  final Key? key;

  final String email;

  @override
  String toString() {
    return 'ForgotPasswordOtpRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForgotPasswordOtpRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [HistoryScreen]
class HistoryRoute extends PageRouteInfo<void> {
  const HistoryRoute({List<PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HistoryScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainScaffoldScreen]
class MainScaffoldRoute extends PageRouteInfo<void> {
  const MainScaffoldRoute({List<PageRouteInfo>? children})
    : super(MainScaffoldRoute.name, initialChildren: children);

  static const String name = 'MainScaffoldRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScaffoldScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    required String email,
    required String otp,
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(key: key, email: email, otp: otp),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>();
      return ResetPasswordScreen(
        key: args.key,
        email: args.email,
        otp: args.otp,
      );
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({
    this.key,
    required this.email,
    required this.otp,
  });

  final Key? key;

  final String email;

  final String otp;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, email: $email, otp: $otp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetPasswordRouteArgs) return false;
    return key == other.key && email == other.email && otp == other.otp;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode ^ otp.hashCode;
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}
