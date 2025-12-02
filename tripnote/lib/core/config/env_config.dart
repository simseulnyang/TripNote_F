import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1';

  static String get kakaoNativeAppKey {
    return dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  }

  static String get kakaoRedirectUri {
    return dotenv.env['KAKAO_REDIRECT_URI'] ?? '';
  }

  static String get kakaoRestApiKey {
    return dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  }

  static String get googleClientId {
    return dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  }

  static String get googleRedirectUri {
    return dotenv.env['GOOGLE_REDIRECT_URI'] ?? '';
  }

  static bool get isKakaoConfigured =>
      kakaoNativeAppKey.isNotEmpty && kakaoRestApiKey.isNotEmpty;

  static bool get isGoogleConfigured => googleClientId.isNotEmpty;
}
