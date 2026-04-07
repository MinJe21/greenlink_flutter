import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:greenlink_front/config/api_config.dart';

/// 공통 HTTP 클라이언트 래퍼
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _buildUri(String path) {
    return Uri.parse('$_baseUrl$path');
  }

  /// GET 요청 헬퍼
  Future<http.Response> getRaw(
    String path, {
    Map<String, String>? headers,
  }) {
    return _client.get(
      _buildUri(path),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await getRaw(path, headers: headers);
    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: decoded['message']?.toString() ?? 'Unexpected error',
    );
  }

  /// POST 요청 헬퍼 (JSON) - body/headers 단순 전달
  Future<http.Response> postRaw(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return _client.post(
      _buildUri(path),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? {}),
    );
  }

  /// POST 요청 후 JSON 디코딩 + 에러 처리
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final response = await postRaw(path, headers: headers, body: body);

    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: decoded['message']?.toString() ?? 'Unexpected error',
    );
  }

  void close() => _client.close();
}

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message});
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
