import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'core/config/env_config.dart';
import 'app.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향 고정 (세로 모드)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 환경변수 로드
  await dotenv.load(fileName: 'assets/.env');

  // 기본 로케일 설정(한국어)
  Intl.defaultLocale = 'ko_KR';
  await initializeDateFormatting();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: EnvConfig.kakaoNativeAppKey,
  );

  // 앱 실행
  runApp(
    const ProviderScope(
      child: TripNoteApp(),
    ),
  );
}
