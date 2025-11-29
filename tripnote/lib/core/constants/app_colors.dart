import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 정의
class AppColors {
  AppColors._();

  /// 메인 브랜드 색상
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFF7AB5F5);
  static const Color primaryDark = Color(0xFF2E6BB5);

  /// 배경 색상
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  /// 텍스트 색상
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// 상태 색상
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  /// 소셜 로그인 버튼 색상
  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color kakaoLabel = Color(0xFF000000);
  static const Color googleWhite = Color(0xFFFFFFFF);
  static const Color googleLabel = Color(0xFF757575);

  /// 그림자 및 구분선
  static const Color shadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE5E7EB);

  /// 네비게이션 바
  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarSelected = Color(0xFF4A90E2);
  static const Color navBarUnselected = Color(0xFF9CA3AF);

  /// 카드 색상
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
}
