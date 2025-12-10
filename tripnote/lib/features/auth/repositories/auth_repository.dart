import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// 카카오 소셜 로그인
  /// [code] - 카카오 OAuth 인가 코드
  /// 반환: [SocialLoginResponse] - JWT 토큰 및 사용자 정보
  Future<SocialLoginResponse> kakaoLogin(String code) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.kakaoLogin,
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        final loginResponse = SocialLoginResponse.fromJson(response.data);
        await _saveAuthData(loginResponse);
        return loginResponse;
      } else {
        throw AuthException('카카오 로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '카카오');
    }
  }

  Future<SocialLoginResponse> kakaoLoginWithToken(String accessToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.kakaoLogin,
        data: {'access_token': accessToken},
      );

      if (response.statusCode == 200) {
        final loginResponse = SocialLoginResponse.fromJson(response.data);
        await _saveAuthData(loginResponse);
        return loginResponse;
      } else {
        throw AuthException('카카오 로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '카카오');
    }
  }

  /// 구글 소셜 로그인
  /// [code] - 구글 OAuth 인가 코드
  /// 반환: [SocialLoginResponse] - JWT 토큰 및 사용자 정보
  Future<SocialLoginResponse> googleLogin(String code) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.googleLogin,
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        final loginResponse = SocialLoginResponse.fromJson(response.data);
        await _saveAuthData(loginResponse);
        return loginResponse;
      } else {
        throw AuthException('구글 로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '구글');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final hasToken = await _storage.hasValidToken();
      if (!hasToken) return null;

      final response = await _apiClient.get(ApiConstants.userMe);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.post(
          ApiConstants.logout,
          data: {'refresh_token': refreshToken},
        );
      }
    } catch (e) {
      print('Server logout failed: $e');
    } finally {
      await _storage.clearAll();
    }
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasValidToken();
  }

  Future<UserModel?> getStoredUser() async {
    final id = await _storage.getUserId();
    final email = await _storage.getUserEmail();
    final nickname = await _storage.getUserNickname();
    final profileImage = await _storage.getUserProfileImage();

    if (id != null && email != null && nickname != null) {
      return UserModel(
        id: id,
        email: email,
        nickname: nickname,
        profileImage: profileImage,
      );
    }
    return null;
  }

  Future<void> _saveAuthData(SocialLoginResponse response) async {
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    await _storage.saveUserInfo(
      id: response.user.id,
      email: response.user.email,
      nickname: response.user.nickname,
      profileImage: response.user.profileImage,
    );
  }

  AuthException _handleDioError(DioException e, String provider) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (statusCode == 400) {
        final detail = data['detail'] ?? '$provider 로그인에 실패했습니다.';
        return AuthException(detail);
      } else if (statusCode == 401) {
        return AuthException('인증이 만료되었습니다. 다시 로그인해주세요.');
      } else if (statusCode == 500) {
        return AuthException('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthException('네트워크 연결 시간이 초과되었습니다.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return AuthException('네트워크에 연결할 수 없습니다.');
    }

    return AuthException('$provider 로그인 중 오류가 발생했습니다.');
  }
}

/// 인증 관련 예외 클래스
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
