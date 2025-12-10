import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../shared/screens/main_screen.dart';

/// 앱 라우트 이름 상수
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String main = '/main';
  static const String login = '/login';
  static const String tripCreate = '/trip/create';
  static const String tripDetail = '/trip/detail';
}

/// 라우트 생성기
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.tripCreate:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('여행 일정 기록하기')),
            body: const Center(child: Text('여행 일정 생성 화면 (구현 예정)')),
          ),
        );

      case AppRoutes.tripDetail:
        final tripId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('여행 상세')),
            body: Center(child: Text('여행 ID: $tripId')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('페이지를 찾을 수 없습니다: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
