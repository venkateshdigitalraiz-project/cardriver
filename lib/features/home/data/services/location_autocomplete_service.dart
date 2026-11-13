import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';

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

class _PlaceItemTemp {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  const _PlaceItemTemp(
    this.placeId,
    this.mainText,
    this.secondaryText,
    this.description,
  );
}

/// Service class for fetching Google Places location autocomplete suggestions & details.
/// Completely decoupled from any Map widget.
class LocationAutocompleteService {
  final String apiKey;
  final http.Client _client;

  /// Default API key configured for Google Places across the project
  static const String defaultApiKey = ApiEndpoints.googleApiKey;

  LocationAutocompleteService({String? apiKey, http.Client? client})
    : apiKey = (apiKey != null && apiKey.isNotEmpty) ? apiKey : defaultApiKey,
      _client = client ?? http.Client();

  /// Fetches matching location suggestions for the given query.
  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    // 1. Try Places API (New) first: POST https://places.googleapis.com/v1/places:autocomplete
    try {
      final url = Uri.parse(
        'https://places.googleapis.com/v1/places:autocomplete',
      );
      final response = await _client
          .post(
            url,
            headers: {
              'X-Goog-Api-Key': apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'input': cleanQuery,
              'includedRegionCodes': ['in'],
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['suggestions'] is List) {
          final List<_PlaceItemTemp> results = [];
          for (final item in data['suggestions']) {
            final pred = item['placePrediction'];
            if (pred != null) {
              final rawPlace = pred['place']?.toString() ?? '';
              final pId =
                  pred['placeId']?.toString() ??
                  (rawPlace.startsWith('places/')
                      ? rawPlace.substring(7)
                      : rawPlace);
              final desc = pred['text']?['text']?.toString() ?? '';
              final main =
                  pred['structuredFormat']?['mainText']?['text']?.toString() ??
                  desc;
              final sec =
                  pred['structuredFormat']?['secondaryText']?['text']
                      ?.toString() ??
                  '';
              if (pId.isNotEmpty) {
                results.add(_PlaceItemTemp(pId, main, sec, desc));
              }
            }
          }
          if (results.isNotEmpty) {
            return results
                .map(
                  (r) => LocationSuggestion(
                    placeId: r.placeId,
                    mainText: r.mainText,
                    secondaryText: r.secondaryText,
                    fullAddress: r.description.isNotEmpty
                        ? r.description
                        : r.mainText,
                  ),
                )
                .toList();
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to Legacy Places Autocomplete
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(cleanQuery)}'
        '&components=country:in'
        '&key=$apiKey',
      );

      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 8));

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

    // 1. Try Places API (New) details first
    try {
      final cleanId = placeId.startsWith('places/')
          ? placeId.substring(7)
          : placeId;
      final url = Uri.parse('https://places.googleapis.com/v1/places/$cleanId');
      final response = await _client
          .get(
            url,
            headers: {
              'X-Goog-Api-Key': apiKey,
              'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['location'] != null) {
          final lat =
              (data['location']['latitude'] as num?)?.toDouble() ??
              double.tryParse(data['location']['latitude'].toString());
          final lng =
              (data['location']['longitude'] as num?)?.toDouble() ??
              double.tryParse(data['location']['longitude'].toString());
          if (lat != null && lng != null) {
            return (lat: lat, lng: lng);
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to Legacy Place Details
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$apiKey',
      );

      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loc = data['result']?['geometry']?['location'];
        if (loc != null) {
          final lat =
              (loc['lat'] as num?)?.toDouble() ??
              double.tryParse(loc['lat'].toString());
          final lng =
              (loc['lng'] as num?)?.toDouble() ??
              double.tryParse(loc['lng'].toString());
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
