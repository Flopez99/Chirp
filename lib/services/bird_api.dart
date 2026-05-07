import 'dart:convert';
import 'package:chirp/config/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/bird.dart';

class BirdApiService {
  static Future<BirdPage> fetchBirdsPage({int limit = 50, int? cursor}) async {
    final params = <String, String>{'limit': '$limit'};
    if (cursor != null) params['cursor'] = '$cursor';

    final uri = ApiConfig.uri("/birds").replace(queryParameters: params);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> items = decoded['items'];
      final nextCursor = decoded['nextCursor'];

      return BirdPage(
        items: items.map((j) => Bird.fromJson(j)).toList(),
        nextCursor: nextCursor == null ? null : (nextCursor as num).toInt(),
      );
    } else {
      throw Exception('Failed to load birds');
    }
  }

  static Future<Bird?> fetchBirdByScientificName(String scientificName) async {
    final uri = ApiConfig.uri(
      "/birds/lookup",
    ).replace(queryParameters: {'scientific': scientificName});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Bird.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Failed to lookup bird');
  }
}

class BirdPage {
  final List<Bird> items;
  final int? nextCursor;
  BirdPage({required this.items, required this.nextCursor});
}
