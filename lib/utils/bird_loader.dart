import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bird.dart';

Future<List<Bird>> loadBirdCatalogue() async {
  final String jsonString = await rootBundle.loadString('assets/birds.json');
  final List<dynamic> data = json.decode(jsonString);
  return data.map((e) => Bird.fromJson(e)).toList();
}
