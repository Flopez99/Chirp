import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class GeocodeService {
  static const String _nominatimUrl =
      'https://nominatim.openstreetmap.org/reverse';

  /// Reverse geocode coordinates to get location name (city, region, etc)
  /// Returns location name or null if failed
  static Future<String?> getLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_nominatimUrl?lat=$latitude&lon=$longitude&format=json&zoom=10&addressdetails=1',
            ),
            headers: {
              'User-Agent': 'ChirpApp/1.0', // Nominatim requires a user agent
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address == null) {
          return null;
        }

        // Try to build a readable location string with city/town, region, and country
        final city = address['city'] ?? address['town'] ?? address['village'];
        final state = address['state'];
        final country = address['country'];

        if (city != null) {
          if (state != null) {
            return '$city, $state, $country';
          }
          return '$city, $country';
        }

        if (state != null && country != null) {
          return '$state, $country';
        }

        return country;
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  /// Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
}
