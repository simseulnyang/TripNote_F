import '../config/env_config.dart';

class ApiConstants {
  ApiConstants._();

  static final String baseUrl = EnvConfig.apiBaseUrl;

  /// 인증 관련 엔드포인트
  static const String authPrefix = '/users';
  static const String kakaoLogin = '$authPrefix/kakao/login/';
  static const String googleLogin = '$authPrefix/google/login/';
  static const String logout = '$authPrefix/logout/';
  static const String tokenRefresh = '$authPrefix/token/refresh/';
  static const String userMe = '$authPrefix/me/';

  /// 여행 일정 관련 엔드포인트
  static const String tripPrefix = '/trips';
  static const String tripList = '$tripPrefix/';
  static const String tripCreate = '$tripPrefix/';

  /// 특정 여행 일정 (ID 필요)
  static String tripDetail(int id) => '$tripPrefix/$id/';
  static String tripUpdate(int id) => '$tripPrefix/$id/';
  static String tripDelete(int id) => '$tripPrefix/$id/';

  /// AI 추천 관련 엔드포인트
  static const String aiPrefix = '/ai';
  static const String aiRecommend = '$aiPrefix/recommend/';
  static const String aiChat = '$aiPrefix/chat/';

  /// 타임아웃 설정 (밀리초)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
