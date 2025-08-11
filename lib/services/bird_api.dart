import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bird.dart';

class BirdApiService {
  static const String _baseUrl =
      'http://127.0.0.1:5000/birds'; // For Android emulator. Use localhost:5000 on web/macOS

  static Future<List<Bird>> fetchBirds() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((birdJson) => Bird.fromJson(birdJson)).toList();
    } else {
      throw Exception('Failed to load birds');
    }
  }
}
