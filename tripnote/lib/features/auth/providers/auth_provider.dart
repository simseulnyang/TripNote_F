import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/config/env_config.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus {
  initial, // 초기 상태 (앱 시작)
  loading, // 로딩 중
  authenticated, // 로그인됨
  unauthenticated, // 비로그인
  error, // 에러 발생
}

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

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final GoogleSignIn _googleSignIn;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: EnvConfig.googleClientId,
    );

    Future.microtask(() => checkAuthStatus());

    return const AuthState(status: AuthStatus.initial);
  }

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

  Future<void> loginWithKakao() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      kakao.OAuthToken token;
      final isKakaoInstalled = await kakao.isKakaoTalkInstalled();

      if (isKakaoInstalled) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          if (e is PlatformException && e.code == 'CANCELED') {
            state = state.copyWith(status: AuthStatus.unauthenticated);
            return;
          }
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      final response =
          await _authRepository.kakaoLoginWithToken(token.accessToken);

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

  /// 구글 로그인
  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final String? serverAuthCode = googleUser.serverAuthCode;
      if (serverAuthCode == null) {
        throw AuthException('구글 인증 코드를 가져올 수 없습니다.\n'
            'Google Cloud Console에서 웹 클라이언트 ID가 올바르게 설정되었는지 확인하세요.');
      }

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
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      try {
        await kakao.UserApi.instance.logout();
      } catch (_) {}

      await _authRepository.logout();

      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});
