import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/app_route.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_login_button.dart';

/// 로그인 화면
/// 카카오, 구글 소셜 로그인 버튼 제공
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.main,
          (route) => false,
        );
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildHeader(),
              const Spacer(flex: 2),
              _buildLoginButtons(isLoading),
              const SizedBox(height: 24),
              _buildTermsText(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '✈️',
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'TripNote',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '나만의 여행 일정을 기록하세요',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(bool isLoading) {
    return Column(
      children: [
        SocialLoginButton(
          type: SocialLoginType.kakao,
          isLoading: isLoading,
          onPressed: () {
            ref.read(authProvider.notifier).loginWithKakao();
          },
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          type: SocialLoginType.google,
          isLoading: isLoading,
          onPressed: () {
            ref.read(authProvider.notifier).loginWithGoogle();
          },
        ),
      ],
    );
  }

  /// 약관 안내 텍스트
  Widget _buildTermsText() {
    return Text(
      '로그인 시 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textHint,
      ),
      textAlign: TextAlign.center,
    );
  }
}
