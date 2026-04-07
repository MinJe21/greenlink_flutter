import 'dart:convert';

import 'package:greenlink_front/config/api_config.dart';
import 'package:greenlink_front/core/api_client.dart';
import 'package:greenlink_front/data/auth_session.dart';
import 'package:http/http.dart' as http;

class PlantService {
  PlantService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Map<String, String> _authHeader() {
    final token = AuthSession.accessToken;
    if (token == null) {
      throw ApiException(statusCode: 401, message: '로그인 토큰이 없습니다.');
    }
    return {'Authorization': token};
  }

  Future<List<PlantSummary>> list() async {
    final res = await _client.getRaw('/api/plant', headers: _authHeader());
    _ensureOk(res);
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => PlantSummary(
              plantId: (e['plantId'] ?? e['id']) as int?,
              name: e['name']?.toString() ?? '',
              category: e['category']?.toString(),
              difficulty: e['difficulty']?.toString(),
              imageUrl: _resolveImageUrl(e),
            ))
        .toList();
  }

  Future<PlantDetail> detail(int plantId) async {
    final res = await _client.getRaw('/api/plant/$plantId', headers: _authHeader());
    _ensureOk(res);
    final e = jsonDecode(res.body) as Map<String, dynamic>;
    return PlantDetail(
      name: e['name']?.toString() ?? '',
      description: e['description']?.toString(),
      category: e['category']?.toString(),
      difficulty: e['difficulty']?.toString(),
      growthPeriodDays: (e['growthPeriodDays'] as num?)?.toInt(),
      lightPref: e['lightPref']?.toString(),
      waterPreMlPerDay: (e['waterPreMlPerDay'] as num?)?.toInt(),
      imageUrl: _resolveImageUrl(e),
      unlockCondition: e['unlockCondition']?.toString(),
    );
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(statusCode: res.statusCode, message: res.body);
    }
  }
}

class PlantSummary {
  PlantSummary({
    required this.plantId,
    required this.name,
    this.category,
    this.difficulty,
    this.imageUrl,
  });

  final int? plantId;
  final String name;
  final String? category;
  final String? difficulty;
  final String? imageUrl;
}

class PlantDetail {
  PlantDetail({
    required this.name,
    this.description,
    this.category,
    this.difficulty,
    this.growthPeriodDays,
    this.lightPref,
    this.waterPreMlPerDay,
    this.imageUrl,
    this.unlockCondition,
  });

  final String name;
  final String? description;
  final String? category;
  final String? difficulty;
  final int? growthPeriodDays;
  final String? lightPref;
  final int? waterPreMlPerDay;
  final String? imageUrl;
  final String? unlockCondition;
}

String? _resolveImageUrl(Map<String, dynamic> e) {
  final raw = (e['imageUrl'] ??
          e['imgUrl'] ??
          e['imageURL'] ??
          e['photoUrl'] ??
          e['lastPhotoUrl'] ??
          e['url'])
      ?.toString();
  if (raw == null || raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri != null && uri.hasScheme) return raw; // absolute (http/https)
  // 상대 경로면 apiBaseUrl 붙이기
  if (raw.startsWith('/')) return '$apiBaseUrl$raw';
  return '$apiBaseUrl/$raw';
}
