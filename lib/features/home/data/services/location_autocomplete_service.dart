import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model representing a location autocomplete suggestion.
class LocationSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullAddress;
  final double? latitude;
  final double? longitude;

  const LocationSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullAddress,
    this.latitude,
    this.longitude,
  });

  LocationSuggestion copyWith({
    String? placeId,
    String? mainText,
    String? secondaryText,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) {
    return LocationSuggestion(
      placeId: placeId ?? this.placeId,
      mainText: mainText ?? this.mainText,
      secondaryText: secondaryText ?? this.secondaryText,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// Service class for fetching Google Places location autocomplete suggestions & details.
/// Completely decoupled from any Map widget.
class LocationAutocompleteService {
  final String apiKey;
  final http.Client _client;

  /// Default API key configured for Google Places across the project
  static const String defaultApiKey =
      'AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s';

  LocationAutocompleteService({
    String? apiKey,
    http.Client? client,
  })  : apiKey = (apiKey != null && apiKey.isNotEmpty) ? apiKey : defaultApiKey,
        _client = client ?? http.Client();

  /// Fetches matching location suggestions for the given query.
  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(cleanQuery)}'
        '&components=country:in'
        '&key=$apiKey',
      );

      final response =
          await _client.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          final List predictions = data['predictions'];
          return predictions.map((p) {
            final desc = p['description']?.toString() ?? '';
            final formatting = p['structured_formatting'];
            final main = formatting?['main_text']?.toString() ?? desc;
            final secondary = formatting?['secondary_text']?.toString() ?? '';
            final placeId = p['place_id']?.toString() ?? '';

            return LocationSuggestion(
              placeId: placeId,
              mainText: main,
              secondaryText: secondary,
              fullAddress: desc.isNotEmpty ? desc : main,
            );
          }).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetches coordinates (latitude, longitude) for a selected place ID.
  Future<({double lat, double lng})?> getPlaceCoordinates(
    String placeId,
  ) async {
    if (placeId.isEmpty) return null;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$apiKey',
      );

      final response =
          await _client.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loc = data['result']?['geometry']?['location'];
        if (loc != null) {
          final lat = double.tryParse(loc['lat'].toString());
          final lng = double.tryParse(loc['lng'].toString());
          if (lat != null && lng != null) {
            return (lat: lat, lng: lng);
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
