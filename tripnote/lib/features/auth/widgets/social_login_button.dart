import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// 소셜 로그인 버튼 타입
enum SocialLoginType {
  kakao,
  google,
}

/// 소셜 로그인 버튼 위젯
///
/// 카카오와 구글 로그인 버튼을 일관된 스타일로 제공
class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _textColor,
          elevation: type == SocialLoginType.google ? 1 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: type == SocialLoginType.google
                ? const BorderSide(color: AppColors.divider)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Text(
                    _buttonText,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: _textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 버튼 배경색
  Color get _backgroundColor {
    switch (type) {
      case SocialLoginType.kakao:
        return AppColors.kakaoYellow;
      case SocialLoginType.google:
        return AppColors.googleWhite;
    }
  }

  /// 텍스트 색상
  Color get _textColor {
    switch (type) {
      case SocialLoginType.kakao:
        return AppColors.kakaoLabel;
      case SocialLoginType.google:
        return AppColors.googleLabel;
    }
  }

  /// 버튼 텍스트
  String get _buttonText {
    switch (type) {
      case SocialLoginType.kakao:
        return '카카오로 시작하기';
      case SocialLoginType.google:
        return 'Google로 시작하기';
    }
  }

  /// 소셜 로고 아이콘
  Widget _buildIcon() {
    switch (type) {
      case SocialLoginType.kakao:
        return _KakaoIcon();
      case SocialLoginType.google:
        return _GoogleIcon();
    }
  }
}

/// 카카오 로고 아이콘
class _KakaoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.kakaoLabel,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '💬',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

/// 구글 로고 아이콘 (간단한 버전)
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
