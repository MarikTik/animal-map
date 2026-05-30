import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Fetches a driving route between two points from the Google Directions API
/// and returns it as a list of [LatLng] points suitable for a [Polyline].
///
/// Requires [apiKey] to be a key with the Directions API enabled.
class DirectionsService {
  DirectionsService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  static const _url = 'https://maps.googleapis.com/maps/api/directions/json';

  /// Returns the route geometry from [origin] to [destination], or an empty
  /// list on error. Logs a non-OK API status so misconfiguration is visible.
  Future<List<LatLng>> route(LatLng origin, LatLng destination) async {
    final uri = Uri.parse(_url).replace(queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': apiKey,
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('Directions HTTP ${response.statusCode}: ${response.body}');
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'] as String?;
      if (status != 'OK') {
        // ignore: avoid_print
        print('Directions status=$status error=${body['error_message']}');
        return [];
      }

      final routes = body['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return [];

      final overview = (routes.first as Map<String, dynamic>)['overview_polyline']
          as Map<String, dynamic>?;
      final encoded = overview?['points'] as String?;
      if (encoded == null) return [];

      return decodePolyline(encoded);
    } catch (e) {
      // ignore: avoid_print
      print('Directions error: $e');
      return [];
    }
  }

  /// Decodes a Google "encoded polyline algorithm" string into [LatLng]s.
  ///
  /// See https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
