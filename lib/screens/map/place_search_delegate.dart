import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/places_service.dart';

/// A [SearchDelegate] that queries the Places Autocomplete API and returns
/// the selected place's [LatLng] via [close].
class PlaceSearchDelegate extends SearchDelegate<LatLng?> {
  PlaceSearchDelegate({required this.placesService});

  final PlacesService placesService;

  List<PlaceSuggestion> _suggestions = [];

  /// The query string the cached [_pendingFuture] was issued for, so rebuilds
  /// of [buildSuggestions] reuse the in-flight request instead of firing a
  /// fresh HTTP call on every frame.
  String? _futureQuery;
  Future<List<PlaceSuggestion>>? _pendingFuture;

  Future<List<PlaceSuggestion>> _suggestionsFor(String query) {
    if (query != _futureQuery || _pendingFuture == null) {
      _futureQuery = query;
      _pendingFuture = placesService.autocomplete(query);
    }
    return _pendingFuture!;
  }

  @override
  String get searchFieldLabel => 'Search location…';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Results are handled via suggestion taps; this is a fallback.
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<PlaceSuggestion>>(
      future: _suggestionsFor(query),
      builder: (context, snapshot) {
        if (query.isEmpty) {
          return const Center(child: Text('Type to search for a location'));
        }

        // While the request for the current query is in flight, show a
        // spinner rather than stale results or a premature "No results".
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        _suggestions = snapshot.data ?? const [];

        if (_suggestions.isEmpty) {
          return const Center(child: Text('No results'));
        }

        return ListView.builder(
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(suggestion.description),
              onTap: () async {
                final latLng =
                    await placesService.getLocation(suggestion.placeId);
                if (context.mounted) close(context, latLng);
              },
            );
          },
        );
      },
    );
  }
}
