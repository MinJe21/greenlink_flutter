import 'dart:convert';

import 'package:greenlink_front/core/api_client.dart';
import 'package:greenlink_front/data/auth_session.dart';
import 'package:http/http.dart' as http;

/// 공용 리소스 서비스 (userPlant, quest, item 등)
class ResourceService {
  ResourceService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Map<String, String> _authHeader() {
    final token = AuthSession.accessToken;
    if (token == null) {
      throw ApiException(statusCode: 401, message: '로그인 토큰이 없습니다.');
    }
    return {'Authorization': token};
  }

  // --- User Plant (내 식물)
  Future<List<Map<String, dynamic>>> fetchUserPlants() async {
    final res = await _client.getRaw('/api/userPlant', headers: _authHeader());
    _ensureOk(res);
    return _decodeList(res.body);
  }

  Future<void> createUserPlant({required String nickname, required int plantId}) async {
    final res = await _client.postRaw(
      '/api/userPlant',
      headers: _authHeader(),
      body: {'nickname': nickname, 'plantId': plantId},
    );
    _ensureOk(res);
  }

  // --- User Quest / Quest
  Future<List<Map<String, dynamic>>> fetchUserQuests() async {
    final res = await _client.getRaw('/api/userQuest', headers: _authHeader());
    _ensureOk(res);
    return _decodeList(res.body);
  }

  Future<List<Map<String, dynamic>>> fetchQuests() async {
    final res = await _client.getRaw('/api/quest', headers: _authHeader());
    _ensureOk(res);
    return _decodeList(res.body);
  }

  // --- User Item / Item
  Future<List<Map<String, dynamic>>> fetchUserItems() async {
    final res = await _client.getRaw('/api/userPlantItem', headers: _authHeader());
    _ensureOk(res);
    return _decodeList(res.body);
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final res = await _client.getRaw('/api/item', headers: _authHeader());
    _ensureOk(res);
    return _decodeList(res.body);
  }

  // helpers
  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(statusCode: res.statusCode, message: res.body);
    }
  }

  List<Map<String, dynamic>> _decodeList(String body) {
    final data = jsonDecode(body);
    if (data is List) {
      return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }
}
