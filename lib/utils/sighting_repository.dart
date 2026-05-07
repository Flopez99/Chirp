import 'package:chirp/config/api_config.dart';
import '../models/bird_sighting.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SightingRepository {
  static Future<List<BirdSighting>> fetchSightings({String? userId}) async {
    final uri = ApiConfig.uri("/sightings").replace(
      queryParameters: userId != null ? {'user_id': userId.toString()} : null,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => BirdSighting.fromJson(json)).toList();
    } else {
      print(response.statusCode);
      print(response.body);

      throw Exception('Failed to load sightings');
    }
  }

  static Future<BirdSighting> addSighting(BirdSighting sighting) async {
    final body = jsonEncode(sighting.toJson());

    final response = await http.post(
      ApiConfig.uri("/sightings/add"),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      return BirdSighting.fromJson(jsonDecode(response.body));
    } else {
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      throw Exception('Failed to add sighting');
    }
  }
}
