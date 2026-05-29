import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/places_service.dart';

/// A [SearchDelegate] that queries the Places Autocomplete API and returns
/// the selected place's [LatLng] via [close].
class PlaceSearchDelegate extends SearchDelegate<LatLng?> {
  PlaceSearchDelegate({required this.placesService});

  final PlacesService placesService;

  List<PlaceSuggestion> _suggestions = [];

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
      future: placesService.autocomplete(query),
      builder: (context, snapshot) {
        _suggestions = snapshot.data ?? _suggestions;

        if (_suggestions.isEmpty) {
          return Center(
            child: query.isEmpty
                ? const Text('Type to search for a location')
                : snapshot.connectionState == ConnectionState.waiting
                    ? const CircularProgressIndicator()
                    : const Text('No results'),
          );
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
