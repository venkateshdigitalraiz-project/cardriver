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

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen> {
  static const String _googleApiKey = 'AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s';

  GoogleMapController? _mapController;
  LatLng _pickedLocation = const LatLng(20.5937, 78.9629);
  bool _loading = true;
  bool _resolving = false;
  bool _isProgrammaticMove = false;
  bool _hasLocationPermission = false;
  PlaceAddressDetails? _resolvedDetails;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      _hasLocationPermission = (permission == LocationPermission.always ||
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
        final List<dynamic> compTypes = comp['types'] ?? [];
        if (compTypes.contains(type)) {
          return comp['long_name']?.toString() ?? '';
        }
      }
    }
    return '';
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

  Future<void> _onSearchResultSelected(Prediction prediction) async {
    _searchFocusNode.unfocus();
    if (prediction.placeId == null) {
      debugPrint('Search result had no placeId');
      return;
    }
    setState(() => _resolving = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${prediction.placeId!}'
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
            final lat = double.tryParse(loc['lat'].toString()) ?? 0.0;
            final lng = double.tryParse(loc['lng'].toString()) ?? 0.0;
            final target = LatLng(lat, lng);
            _pickedLocation = target;
            _isProgrammaticMove = true;

            final List<dynamic> components =
                details['address_components'] ?? [];
            final rawFormatted = details['formatted_address']?.toString() ?? '';
            final formattedAddress = cleanAddressString(rawFormatted);
            var shortAddress = buildShortAddress(components);
            if (shortAddress.isEmpty) shortAddress = formattedAddress;

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

            if (mounted) {
              setState(() {
                _resolvedDetails = PlaceAddressDetails(
                  formattedAddress: formattedAddress,
                  shortAddress: shortAddress,
                  city: city,
                  state: state,
                  pincode: pincode,
                  lat: lat,
                  lng: lng,
                  googleMapsUrl: PlaceAddressDetails.buildMapsUrl(lat, lng),
                  cityCandidates: extractCityCandidates(components),
                );
              });
            }

            await _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(target, 17),
            );
          }
        } else {
          debugPrint(
            'Place Details API returned: ${data['status']} - ${data['error_message']}',
          );
        }
      } else {
        debugPrint('HTTP error fetching place details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching place details for search result: $e');
    } finally {
      if (mounted) setState(() => _resolving = false);
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
    final String screenTitle = widget.title ??
        (widget.isPickup == true
            ? 'Pickup Location'
            : widget.isPickup == false
                ? 'Drop Location'
                : 'Pick Location');

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
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _searchController,
                    focusNode: _searchFocusNode,
                    googleAPIKey: _googleApiKey,
                    debounceTime: 400,
                    countries: const ['in'],
                    isLatLngRequired: false,
                    showError: false,
                    isCrossBtnShown: false,
                    boxDecoration: BoxDecoration(
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
                    inputDecoration: InputDecoration(
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
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
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
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    itemClick: (Prediction prediction) {
                      _searchController.text = prediction.description ?? '';
                      _onSearchResultSelected(prediction);
                    },
                    seperatedBuilder: const Divider(
                      color: AppColors.borderLight,
                      height: 1,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index, Prediction prediction) {
                      final String mainText =
                          prediction.structuredFormatting?.mainText ??
                          prediction.description ??
                          '';
                      final String secondaryText =
                          prediction.structuredFormatting?.secondaryText ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: AppColors.white,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mainText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (secondaryText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      secondaryText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                              : (_resolvedDetails?.shortAddress.isNotEmpty == true
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
