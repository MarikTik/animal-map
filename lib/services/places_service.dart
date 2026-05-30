import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// A single autocomplete suggestion returned by the Places API.
class PlaceSuggestion {
  const PlaceSuggestion({required this.placeId, required this.description});

  final String placeId;
  final String description;

  @override
  String toString() => description;
}

/// Thin wrapper around the Google Places Autocomplete and Place Details APIs.
///
/// Requires [apiKey] to be a key with the Places API (New) enabled.
class PlacesService {
  PlacesService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  /// The status / error of the most recent [autocomplete] call, for surfacing
  /// in the UI during debugging. `null` after a successful call with results.
  String? lastStatus;

  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  /// Returns up to 5 autocomplete suggestions for [query].
  ///
  /// Returns an empty list on network error or when [query] is blank.
  /// Logs the Places API status when it is not `OK`/`ZERO_RESULTS` so
  /// misconfigurations (e.g. `REQUEST_DENIED`) are visible during debugging.
  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_autocompleteUrl).replace(queryParameters: {
      'input': query,
      'key': apiKey,
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        lastStatus = 'HTTP ${response.statusCode}';
        // ignore: avoid_print
        print('Places autocomplete HTTP ${response.statusCode}: ${response.body}');
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        // REQUEST_DENIED, OVER_QUERY_LIMIT, INVALID_REQUEST, etc.
        lastStatus = '$status: ${body['error_message'] ?? ''}'.trim();
        // ignore: avoid_print
        print('Places autocomplete status=$status '
            'error=${body['error_message']}');
        return [];
      }

      lastStatus = null;
      final predictions = body['predictions'] as List<dynamic>? ?? [];

      return predictions
          .cast<Map<String, dynamic>>()
          .map((p) => PlaceSuggestion(
                placeId: p['place_id'] as String,
                description: p['description'] as String,
              ))
          .toList();
    } catch (e) {
      lastStatus = 'Network error: $e';
      // ignore: avoid_print
      print('Places autocomplete error: $e');
      return [];
    }
  }

  /// Resolves the [LatLng] for a given [placeId].
  ///
  /// Returns `null` on error or if the place has no geometry.
  Future<LatLng?> getLocation(String placeId) async {
    final uri = Uri.parse(_detailsUrl).replace(queryParameters: {
      'place_id': placeId,
      'fields': 'geometry',
      'key': apiKey,
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final result = body['result'] as Map<String, dynamic>?;
      final location =
          (result?['geometry'] as Map<String, dynamic>?)?['location']
              as Map<String, dynamic>?;

      if (location == null) return null;

      return LatLng(
        (location['lat'] as num).toDouble(),
        (location['lng'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}
