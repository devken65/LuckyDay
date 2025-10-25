import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:template/features/music_player/models/music_info.dart';

/// 음악 검색 Repository
class MusicSearchRepository {
  static const _itunesApiUrl = 'https://itunes.apple.com/search';

  /// 음악 검색 (iTunes API)
  Future<List<MusicInfo>> searchMusic({
    required String query,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(_itunesApiUrl).replace(
        queryParameters: {
          'term': query,
          'media': 'music',
          'entity': 'song',
          'limit': limit.toString(),
        },
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to search music: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      return results
          .map((item) => MusicInfo.fromItunesJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search music: $e');
    }
  }

  /// 특정 곡 정보 가져오기 (아티스트 + 제목으로 검색)
  Future<MusicInfo?> getMusicInfo({
    required String artist,
    required String title,
  }) async {
    try {
      final query = '$artist $title';
      final results = await searchMusic(query: query, limit: 1);

      if (results.isEmpty) {
        return null;
      }

      return results.first;
    } on Exception {
      return null;
    }
  }
}
