import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNicknameKey = 'user_nickname';
  static const String _userProfileImageKey = 'user_profile_image';

  // ==================== Access Token ====================

  /// Access Token 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Access Token 조회
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Access Token 삭제
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  // ==================== Refresh Token ====================

  /// Refresh Token 저장
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Refresh Token 조회
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Refresh Token 삭제
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // ==================== 토큰 일괄 관리 ====================

  /// Access Token과 Refresh Token 모두 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// 모든 토큰 삭제
  Future<void> deleteAllTokens() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
    ]);
  }

  /// 토큰 존재 여부 확인
  Future<bool> hasValidToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // ==================== 사용자 정보 ====================

  /// 사용자 정보 저장
  Future<void> saveUserInfo({
    required int id,
    required String email,
    required String nickname,
    String? profileImage,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: id.toString()),
      _storage.write(key: _userEmailKey, value: email),
      _storage.write(key: _userNicknameKey, value: nickname),
      if (profileImage != null)
        _storage.write(key: _userProfileImageKey, value: profileImage),
    ]);
  }

  /// 사용자 ID 조회
  Future<int?> getUserId() async {
    final idStr = await _storage.read(key: _userIdKey);
    return idStr != null ? int.tryParse(idStr) : null;
  }

  /// 사용자 이메일 조회
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// 사용자 닉네임 조회
  Future<String?> getUserNickname() async {
    return await _storage.read(key: _userNicknameKey);
  }

  /// 사용자 프로필 이미지 조회
  Future<String?> getUserProfileImage() async {
    return await _storage.read(key: _userProfileImageKey);
  }

  /// 사용자 정보 삭제
  Future<void> deleteUserInfo() async {
    await Future.wait([
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userNicknameKey),
      _storage.delete(key: _userProfileImageKey),
    ]);
  }

  // ==================== 전체 삭제 ====================

  /// 모든 저장된 데이터 삭제 (로그아웃 시 사용)
  Future<void> clearAll() async {
    await Future.wait([
      deleteAllTokens(),
      deleteUserInfo(),
    ]);
  }
}
