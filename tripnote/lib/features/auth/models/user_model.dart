/// 사용자 정보 모델
///
/// DRF UserSerializer와 매핑
class UserModel {
  final int id;
  final String email;
  final String nickname;
  final String? profileImage;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImage,
    this.createdAt,
  });

  /// JSON → UserModel 변환
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profile_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// UserModel → JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  UserModel copyWith({
    int? id,
    String? email,
    String? nickname,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 소셜 로그인 응답 모델
///
/// DRF SocialLoginResponseSerializer와 매핑
class SocialLoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final bool isCreated;

  SocialLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isCreated,
  });

  /// JSON → SocialLoginResponse 변환
  factory SocialLoginResponse.fromJson(Map<String, dynamic> json) {
    return SocialLoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      isCreated: json['is_created'] as bool,
    );
  }

  @override
  String toString() {
    return 'SocialLoginResponse(user: ${user.email}, isCreated: $isCreated)';
  }
}
