import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/config/env_config.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// ============================================================
// 인증 상태 정의
// ============================================================

/// 인증 상태 열거형
enum AuthStatus {
  initial, // 초기 상태 (앱 시작)
  loading, // 로딩 중
  authenticated, // 로그인됨
  unauthenticated, // 비로그인
  error, // 에러 발생
}

/// 인증 상태 모델 (Immutable)
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isNewUser = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  bool get isLoggedIn => status == AuthStatus.authenticated && user != null;
}

// ============================================================
// Riverpod 2.0+ Notifier 방식
// ============================================================

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// 인증 상태 관리 Notifier (Riverpod 2.0+ 스타일)
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  // Google Sign In 인스턴스 (6.x 버전용)
  // pubspec.yaml에서 google_sign_in: ^6.2.1 로 고정 필요
  late final GoogleSignIn _googleSignIn;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    // Google Sign In 초기화 (6.x 버전 방식)
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: EnvConfig.googleClientId,
    );

    // 초기 상태 반환 후 인증 상태 확인
    Future.microtask(() => checkAuthStatus());

    return const AuthState(status: AuthStatus.initial);
  }

  /// 앱 시작 시 인증 상태 확인
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authRepository.getStoredUser();
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          return;
        }
      }

      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// 카카오 로그인
  Future<void> loginWithKakao() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    print('🟡 카카오 로그인 시작...');

    try {
      kakao.OAuthToken token;

      // 카카오톡 설치 여부 확인
      final isKakaoInstalled = await kakao.isKakaoTalkInstalled();
      print('🟡 카카오톡 설치 여부: $isKakaoInstalled');

      if (isKakaoInstalled) {
        try {
          print('🟡 카카오톡으로 로그인 시도...');
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
          print('🟢 카카오톡 로그인 성공!');
        } catch (e) {
          print('🟠 카카오톡 로그인 실패: $e');
          if (e is PlatformException && e.code == 'CANCELED') {
            state = state.copyWith(status: AuthStatus.unauthenticated);
            return;
          }
          print('🟡 카카오계정으로 로그인 시도...');
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          print('🟢 카카오계정 로그인 성공!');
        }
      } else {
        print('🟡 카카오계정으로 로그인 시도...');
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        print('🟢 카카오계정 로그인 성공!');
      }

      print('🟢 카카오 토큰 획득: ${token.accessToken.substring(0, 20)}...');

      // 백엔드로 accessToken 전송
      print('🟡 백엔드로 토큰 전송 중...');
      final response =
          await _authRepository.kakaoLoginWithToken(token.accessToken);
      print('🟢 백엔드 응답 성공!');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        isNewUser: response.isCreated,
        errorMessage: null,
      );
    } on kakao.KakaoAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '카카오 인증 실패: ${e.message}',
      );
    } on kakao.KakaoException catch (e) {
      if (e.toString().contains('CANCELED') ||
          e.toString().contains('cancelled')) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '카카오 로그인 실패: ${e.message}',
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '카카오 로그인 중 오류 발생: $e',
      );
    }
  }

  /// 구글 로그인 (google_sign_in 6.x 버전)
  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      // 기존 로그인 정보 정리
      await _googleSignIn.signOut();

      // 구글 로그인 시도
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      // serverAuthCode 획득
      final String? serverAuthCode = googleUser.serverAuthCode;

      if (serverAuthCode == null) {
        throw AuthException('구글 인증 코드를 가져올 수 없습니다.\n'
            'Google Cloud Console에서 웹 클라이언트 ID가 올바르게 설정되었는지 확인하세요.');
      }

      // 백엔드로 인가 코드 전송
      final response = await _authRepository.googleLogin(serverAuthCode);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        isNewUser: response.isCreated,
        errorMessage: null,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: '구글 로그인 중 오류 발생: $e',
      );
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // 구글 로그아웃
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // 카카오 로그아웃
      try {
        await kakao.UserApi.instance.logout();
      } catch (_) {}

      // 백엔드 로그아웃
      await _authRepository.logout();

      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// Auth Notifier Provider (Riverpod 2.0+)
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// 로그인 상태 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

/// 현재 사용자 Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// 인증 상태 Provider
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});
