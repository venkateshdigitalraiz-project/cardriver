import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../style/app_colors.dart';
import '../utils/place_address_utils.dart';

class LocationPickerMapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? title;
  final bool? isPickup;

  const LocationPickerMapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.title,
    this.isPickup,
  });

  @override
  State<LocationPickerMapScreen> createState() =>
      _LocationPickerMapScreenState();
}

class _PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  const _PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });
}

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen> {
  static const String _googleApiKey = 'AIzaSyBpCA99uGvcf267xPpDxv1dWsFkOqB3RYU';

  GoogleMapController? _mapController;
  LatLng _pickedLocation = const LatLng(20.5937, 78.9629);
  bool _loading = true;
  bool _resolving = false;
  bool _isProgrammaticMove = false;
  bool _hasLocationPermission = false;
  PlaceAddressDetails? _resolvedDetails;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<_PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
    _initLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchQueryChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged() {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      if (_suggestions.isNotEmpty || _isSearching) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _fetchPlaceSuggestions(query);
    });
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      _hasLocationPermission =
          (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse);

      if (widget.initialLat != null && widget.initialLng != null) {
        _pickedLocation = LatLng(widget.initialLat!, widget.initialLng!);
        await _reverseGeocode(_pickedLocation);
        if (mounted) setState(() => _loading = false);
        return;
      }

      if (!_hasLocationPermission) {
        if (mounted) setState(() => _loading = false);
        await _reverseGeocode(_pickedLocation);
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _loading = false);
        await _reverseGeocode(_pickedLocation);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _pickedLocation = LatLng(position.latitude, position.longitude);
      await _reverseGeocode(_pickedLocation);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      await _reverseGeocode(_pickedLocation);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _extractComponent(List<dynamic> components, List<String> types) {
    for (final type in types) {
      for (final comp in components) {
        if (comp is Map) {
          final List<dynamic> compTypes = comp['types'] ?? [];
          if (compTypes.contains(type)) {
            final val = comp['longText'] ?? comp['long_name'];
            if (val != null && val.toString().trim().isNotEmpty) {
              return val.toString().trim();
            }
          }
        }
      }
    }
    return '';
  }

  Future<void> _fetchPlaceSuggestions(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    final List<_PlaceSuggestion> results = [];

    // 1. Try Places API (New) first: POST https://places.googleapis.com/v1/places:autocomplete
    try {
      final url = Uri.parse(
        'https://places.googleapis.com/v1/places:autocomplete',
      );
      final response = await http.post(
        url,
        headers: {
          'X-Goog-Api-Key': _googleApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': query,
          'includedRegionCodes': ['in'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['suggestions'] is List) {
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
                results.add(
                  _PlaceSuggestion(
                    placeId: pId,
                    mainText: main,
                    secondaryText: sec,
                    description: desc.isNotEmpty ? desc : main,
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Places API (New) autocomplete error: $e');
    }

    // 2. If Places API (New) returned no results, fallback to legacy Places Autocomplete
    if (results.isEmpty) {
      try {
        final legacyUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&components=country:in'
          '&key=$_googleApiKey',
        );
        final legacyResp = await http.get(legacyUrl);
        if (legacyResp.statusCode == 200) {
          final data = json.decode(legacyResp.body);
          if (data['status'] == 'OK' && data['predictions'] is List) {
            for (final p in data['predictions']) {
              final pId = p['place_id']?.toString() ?? '';
              final desc = p['description']?.toString() ?? '';
              final main =
                  p['structured_formatting']?['main_text']?.toString() ?? desc;
              final sec =
                  p['structured_formatting']?['secondary_text']?.toString() ??
                  '';
              if (pId.isNotEmpty) {
                results.add(
                  _PlaceSuggestion(
                    placeId: pId,
                    mainText: main,
                    secondaryText: sec,
                    description: desc.isNotEmpty ? desc : main,
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Legacy places autocomplete error: $e');
      }
    }

    if (mounted) {
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    if (mounted) setState(() => _resolving = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${position.latitude},${position.longitude}'
        '&key=$_googleApiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            (data['results'] as List).isNotEmpty) {
          final results = data['results'] as List<dynamic>;
          // Prefer the first result that is not purely a plus_code
          final result = results.firstWhere(
            (r) => !(r['types'] as List<dynamic>? ?? []).contains('plus_code'),
            orElse: () => results[0],
          );
          final List<dynamic> components = result['address_components'] ?? [];
          final rawFormatted = result['formatted_address']?.toString() ?? '';
          final formattedAddress = cleanAddressString(rawFormatted);
          final city = _extractComponent(components, [
            'locality',
            'administrative_area_level_2',
            'sublocality',
            'sublocality_level_1',
          ]);
          final state = _extractComponent(components, [
            'administrative_area_level_1',
          ]);
          final pincode = _extractComponent(components, ['postal_code']);
          var shortAddress = buildShortAddress(components);
          if (shortAddress.isEmpty) shortAddress = formattedAddress;
          if (mounted) {
            setState(() {
              _resolvedDetails = PlaceAddressDetails(
                formattedAddress: formattedAddress,
                shortAddress: shortAddress,
                city: city,
                state: state,
                pincode: pincode,
                lat: position.latitude,
                lng: position.longitude,
                googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
                  position.latitude,
                  position.longitude,
                ),
                cityCandidates: extractCityCandidates(components),
              );
            });
          }
        } else {
          debugPrint('Geocode API returned: ${data['status']}');
          if (_resolvedDetails == null && mounted) {
            setState(() {
              _resolvedDetails = PlaceAddressDetails(
                formattedAddress:
                    'Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
                shortAddress:
                    'Selected Pin (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)})',
                city: '',
                state: '',
                pincode: '',
                lat: position.latitude,
                lng: position.longitude,
                googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
                  position.latitude,
                  position.longitude,
                ),
              );
            });
          }
        }
      } else {
        debugPrint('HTTP error during reverse geocode: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _onSearchResultSelected(_PlaceSuggestion suggestion) async {
    _searchFocusNode.unfocus();
    _searchController.text = suggestion.description;
    setState(() {
      _suggestions = [];
      _resolving = true;
    });

    double? lat;
    double? lng;
    String formattedAddress = suggestion.description;
    String shortAddress = suggestion.mainText;
    String city = '';
    String state = '';
    String pincode = '';
    List<dynamic> components = [];

    // 1. Try Places API (New) Place Details first
    try {
      final cleanId = suggestion.placeId.startsWith('places/')
          ? suggestion.placeId.substring(7)
          : suggestion.placeId;
      final url = Uri.parse('https://places.googleapis.com/v1/places/$cleanId');
      final response = await http.get(
        url,
        headers: {
          'X-Goog-Api-Key': _googleApiKey,
          'X-Goog-FieldMask':
              'id,displayName,formattedAddress,location,addressComponents',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map) {
          if (data['location'] != null) {
            lat = double.tryParse(data['location']['latitude'].toString());
            lng = double.tryParse(data['location']['longitude'].toString());
          }
          if (data['formattedAddress'] != null) {
            formattedAddress = cleanAddressString(
              data['formattedAddress'].toString(),
            );
          }
          final dispName = data['displayName']?['text']?.toString();
          if (dispName != null && dispName.trim().isNotEmpty) {
            shortAddress = dispName.trim();
          }
          if (data['addressComponents'] is List) {
            components = data['addressComponents'];
            city = _extractComponent(components, [
              'locality',
              'administrative_area_level_2',
              'sublocality',
              'sublocality_level_1',
            ]);
            state = _extractComponent(components, [
              'administrative_area_level_1',
            ]);
            pincode = _extractComponent(components, ['postal_code']);
          }
        }
      }
    } catch (e) {
      debugPrint('Places API (New) details error: $e');
    }

    // 2. If lat/lng still null, try Legacy Place Details
    if (lat == null || lng == null) {
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=${suggestion.placeId}'
          '&fields=geometry,address_components,formatted_address'
          '&key=$_googleApiKey',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && data['result'] != null) {
            final details = data['result'];
            final loc = details['geometry']?['location'];
            if (loc != null) {
              lat = double.tryParse(loc['lat'].toString());
              lng = double.tryParse(loc['lng'].toString());
              components = details['address_components'] ?? [];
              final rawFormatted =
                  details['formatted_address']?.toString() ?? '';
              formattedAddress = cleanAddressString(rawFormatted);
              final builtShort = buildShortAddress(components);
              if (builtShort.isNotEmpty) shortAddress = builtShort;

              city = _extractComponent(components, [
                'locality',
                'administrative_area_level_2',
                'sublocality',
                'sublocality_level_1',
              ]);
              state = _extractComponent(components, [
                'administrative_area_level_1',
              ]);
              pincode = _extractComponent(components, ['postal_code']);
            }
          }
        }
      } catch (e) {
        debugPrint('Legacy place details error: $e');
      }
    }

    final effectiveLat = lat ?? _pickedLocation.latitude;
    final effectiveLng = lng ?? _pickedLocation.longitude;
    final target = LatLng(effectiveLat, effectiveLng);
    _pickedLocation = target;
    _isProgrammaticMove = true;

    final detailsObj = PlaceAddressDetails(
      formattedAddress: formattedAddress.isNotEmpty
          ? formattedAddress
          : suggestion.description,
      shortAddress: shortAddress.isNotEmpty
          ? shortAddress
          : suggestion.mainText,
      city: city,
      state: state,
      pincode: pincode,
      lat: effectiveLat,
      lng: effectiveLng,
      googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
        effectiveLat,
        effectiveLng,
      ),
      cityCandidates: extractCityCandidates(components),
    );

    if (mounted) {
      setState(() {
        _resolvedDetails = detailsObj;
        _resolving = false;
      });

      if (lat != null && lng != null) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(target, 17),
        );
      }
    }
  }

  void _onCameraIdle() {
    if (_isProgrammaticMove) {
      _isProgrammaticMove = false;
      return;
    }
    _reverseGeocode(_pickedLocation);
  }

  void _onCameraMove(CameraPosition position) {
    _isProgrammaticMove = false;
    _pickedLocation = position.target;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final String screenTitle =
        widget.title ??
        (widget.isPickup == true ? 'Pickup Location' : 'Drop Location');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _pickedLocation,
                    zoom: 16,
                  ),
                  mapType: MapType.normal,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: _hasLocationPermission,
                  myLocationButtonEnabled: _hasLocationPermission,
                  zoomControlsEnabled: false,
                  padding: const EdgeInsets.only(top: 72),
                ),
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.location_on,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            hintText: widget.isPickup == true
                                ? 'Search for pickup location (e.g. Ameerpet)'
                                : widget.isPickup == false
                                ? 'Search for drop location (e.g. Hitec City)'
                                : 'Search for a location (e.g. Ameerpet)',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _suggestions = []);
                                    },
                                  )
                                : (_isSearching
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        )
                                      : null),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_suggestions.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 240),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) => const Divider(
                              color: AppColors.borderLight,
                              height: 1,
                              thickness: 1,
                            ),
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return InkWell(
                                onTap: () =>
                                    _onSearchResultSelected(suggestion),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              suggestion.mainText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (suggestion
                                                .secondaryText
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                suggestion.secondaryText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24 + bottomPadding,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _resolving
                              ? 'Locating...'
                              : (_resolvedDetails?.shortAddress.isNotEmpty ==
                                        true
                                    ? _resolvedDetails!.shortAddress
                                    : (_resolvedDetails?.formattedAddress ??
                                          'Move the map to select a location')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_resolving &&
                            _resolvedDetails != null &&
                            _resolvedDetails!.formattedAddress.isNotEmpty &&
                            _resolvedDetails!.formattedAddress !=
                                _resolvedDetails!.shortAddress) ...[
                          const SizedBox(height: 4),
                          Text(
                            _resolvedDetails!.formattedAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _resolvedDetails == null
                                ? null
                                : () => context.pop(_resolvedDetails),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Confirm $screenTitle',
                              style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
