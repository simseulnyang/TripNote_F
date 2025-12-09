import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/secure_storage.dart';

/// Dio HTTP 클라이언트 설정
///
/// - 기본 URL 설정
/// - 타임아웃 설정
/// - 인터셉터 (토큰 자동 첨부, 에러 처리)
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final SecureStorage _storage = SecureStorage();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(_LoggingInterceptor());
  }

  Dio get dio => _dio;

  // ==================== HTTP 메서드 래퍼 ====================

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// 인증 인터셉터 - 토큰 자동 첨부 및 갱신
class _AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰이 필요없는 엔드포인트 목록
    final noAuthPaths = [
      ApiConstants.kakaoLogin,
      ApiConstants.googleLogin,
    ];

    // 토큰 불필요한 요청은 그대로 진행
    if (noAuthPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    // Access Token 첨부
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized - 토큰 만료
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // 토큰 갱신 시도
          final response = await _dio.post(
            ApiConstants.tokenRefresh,
            data: {'refresh': refreshToken},
            options: Options(
              headers: {'Authorization': null}, // 기존 토큰 제거
            ),
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'];
            await _storage.saveAccessToken(newAccessToken);

            // 원래 요청 재시도
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // 토큰 갱신 실패 - 로그아웃 처리
          await _storage.clearAll();
        }
      }
    }

    return handler.next(err);
  }
}

/// 로깅 인터셉터 - 디버깅용
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    print('   Headers: ${options.headers}');
    if (options.data != null) {
      print('   Data: ${options.data}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('   Message: ${err.message}');
    return handler.next(err);
  }
}
