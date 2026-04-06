import 'package:greenlink_front/core/api_client.dart';

/// 로그인/회원가입 API 전용 서비스 (Spring Boot 연동)
class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// 1) `/api/login` 에 username/password 전송 → RefreshToken 헤더 수신
  /// 2) `/api/auth` 에 RefreshToken 헤더로 요청 → Authorization 헤더로 AccessToken 수신
  /// 반환: (refreshToken, accessToken)
  Future<({String refreshToken, String accessToken})> login({
    required String username,
    required String password,
  }) async {
    // 1단계: 로그인하여 Refresh Token 헤더 획득
    final loginResp = await _client.postRaw(
      '/api/login',
      body: {
        'username': username,
        'password': password,
      },
    );

    final refreshToken = _readHeader(loginResp.headers, 'RefreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException(statusCode: loginResp.statusCode, message: 'RefreshToken 헤더가 없습니다.');
    }

    // 2단계: Refresh Token으로 Access Token 발급
    final accessResp = await _client.postRaw(
      '/api/auth',
      headers: {
        'RefreshToken': refreshToken,
      },
    );

    final accessToken = _readHeader(accessResp.headers, 'Authorization');
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(statusCode: accessResp.statusCode, message: 'Authorization 헤더가 없습니다.');
    }

    if (accessResp.statusCode < 200 || accessResp.statusCode >= 300) {
      throw ApiException(statusCode: accessResp.statusCode, message: 'AccessToken 발급 실패');
    }

    return (refreshToken: refreshToken, accessToken: accessToken);
  }

  /// 회원가입: `/api/user/signup` POST
  /// 서버 DTO 필드와 동일하게 보냅니다.
  Future<int> signup({
    required String username,
    required String password,
    required String email,
    required String nickname,
    required String phoneNumber,
    required String address,
  }) async {
    final json = await _client.post(
      '/api/user/signup',
      body: {
        'username': username,
        'password': password,
        'email': email,
        'nickname': nickname,
        'phoneNumber': phoneNumber,
        'address': address,
      },
    );

    final userId = json['userId'];
    if (userId == null) {
      throw ApiException(statusCode: 500, message: 'userId가 응답에 없습니다.');
    }
    return (userId as num).toInt();
  }

  /// 헤더 키를 대소문자 구분 없이 조회
  String? _readHeader(Map<String, String> headers, String key) {
    final lowerKey = key.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == lowerKey) {
        return entry.value;
      }
    }
    return null;
  }
}
