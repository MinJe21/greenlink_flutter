/// API 환경설정
/// 기본값은 Android 에뮬레이터에서 호스트 머신의 8080 포트를 바라보도록 되어 있습니다.
/// 실제 서버 주소는 빌드 시 `--dart-define=API_BASE_URL=...` 로 주입하세요.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
