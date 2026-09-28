import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LocationService {
  final http.Client _client;

  LocationService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    final trimmedAddress = address.trim();
    if (trimmedAddress.isEmpty) return null;

    try {
      final encodedAddress = Uri.encodeComponent(trimmedAddress);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'EstarKoApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final first = data.first as Map<String, dynamic>;
          final latString = first['lat']?.toString();
          final lonString = first['lon']?.toString();

          if (latString != null && lonString != null) {
            final lat = double.tryParse(latString);
            final lon = double.tryParse(lonString);

            if (lat != null && lon != null) {
              return {
                'latitude': lat,
                'longitude': lon,
                'lat': lat,
                'lon': lon,
              };
            }
          }
        }
      } else {
        debugPrint(
          'LocationService error: HTTP ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('LocationService geocoding failed: $e');
    }

    return null;
  }
}
