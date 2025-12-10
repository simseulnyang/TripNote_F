import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

/// 내 정보 화면
///
/// - 비로그인: 로그인 화면 표시
/// - 로그인: 프로필 정보 + 메뉴 표시
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;

    // 비로그인 상태면 로그인 화면 표시
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    final user = authState.user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),

              // 프로필 카드
              _buildProfileCard(user.nickname, user.email, user.profileImage),

              const SizedBox(height: 24),

              // 메뉴 섹션
              _buildMenuSection(context, ref),

              const SizedBox(height: 24),

              // 앱 정보
              _buildAppInfo(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '내 정보',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// 프로필 카드
  Widget _buildProfileCard(
      String nickname, String email, String? profileImage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: profileImage != null && profileImage.isNotEmpty
                ? NetworkImage(profileImage)
                : null,
            child: profileImage == null || profileImage.isEmpty
                ? Text(
                    nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 편집 버튼
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.textSecondary,
            onPressed: () {
              // TODO: 프로필 편집 화면
            },
          ),
        ],
      ),
    );
  }

  /// 메뉴 섹션
  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.history_outlined,
            title: '여행 기록',
            subtitle: '내가 기록한 여행 일정',
            onTap: () {
              // TODO: 여행 기록 목록
            },
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.bookmark_outline,
            title: '저장한 추천',
            subtitle: 'AI가 추천한 일정 모음',
            onTap: () {
              // TODO: 저장한 추천 목록
            },
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            onTap: () {
              // TODO: 알림 설정
            },
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.help_outline,
            title: '도움말',
            onTap: () {
              // TODO: 도움말
            },
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.logout,
            title: '로그아웃',
            textColor: AppColors.error,
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  /// 앱 정보
  Widget _buildAppInfo() {
    return Column(
      children: [
        Text(
          'TripNote',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'v1.0.0',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: Text(
              '로그아웃',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 메뉴 타일 위젯
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }
}
