import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── PlaceAddressDetails ─────────────────────────────────────────────────────

class PlaceAddressDetails {
  final String formattedAddress;
  final String shortAddress;
  final String city;
  final String state;
  final String pincode;
  final double lat;
  final double lng;
  final String googleMapsUrl;
  final List<String> cityCandidates;

  const PlaceAddressDetails({
    required this.formattedAddress,
    required this.shortAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.lat,
    required this.lng,
    required this.googleMapsUrl,
    this.cityCandidates = const [],
  });

  static String buildMapsUrl(double lat, double lng) =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
}

// ─── Address helpers ──────────────────────────────────────────────────────────

/// Cleans an address string by removing:
/// - Stray dollar signs ($) or escaped placeholders
/// - Google Plus Codes (e.g. '8F52+9X', 'CF7M+G8', '7J4VCF7M+G8', or '8F52+9X4, ')
/// - Leading/trailing commas and whitespace
String cleanAddressString(String address) {
  if (address.isEmpty) return address;

  var cleaned = address;

  // 1. Remove stray dollar signs
  cleaned = cleaned.replaceAll(r'$', '');

  // 2. Remove Plus Codes (e.g. '8F52+9X, ' or 'CF7M+G8, ' or '7J4VCF7M+G8, ')
  final plusCodeRegex = RegExp(
    r'\b[A-Z0-9]{4,8}\+[A-Z0-9]{2,4}(,\s*)?',
    caseSensitive: false,
  );
  cleaned = cleaned.replaceAll(plusCodeRegex, '');

  // 3. Remove multiple commas or commas at start/end
  cleaned = cleaned
      .replaceAll(RegExp(r',\s*,+'), ', ')
      .replaceAll(RegExp(r'^\s*,\s*'), '')
      .replaceAll(RegExp(r'\s*,\s*$'), '')
      .trim();

  return cleaned;
}

/// Extracts a concise human-readable address from Google address_components.
String buildShortAddress(List<dynamic> components) {
  final premise = _component(components, ['premise', 'subpremise']);
  final streetNumber = _component(components, ['street_number']);
  final route = _component(components, ['route']);
  final sublocality = _component(
    components,
    ['sublocality_level_1', 'sublocality', 'neighborhood'],
  );
  final locality = _component(components, ['locality']);
  final admin2 = _component(components, ['administrative_area_level_2']);

  final rawParts = <String>[];

  if (premise.isNotEmpty) {
    rawParts.add(premise);
  }

  // Combine street number and route cleanly without dollar signs
  if (streetNumber.isNotEmpty && route.isNotEmpty) {
    rawParts.add('$streetNumber, $route');
  } else if (streetNumber.isNotEmpty) {
    rawParts.add(streetNumber);
  } else if (route.isNotEmpty) {
    rawParts.add(route);
  }

  // Avoid repeating if route already equals or contains sublocality
  if (sublocality.isNotEmpty) {
    final alreadyExists = rawParts.any(
      (p) =>
          p.toLowerCase().contains(sublocality.toLowerCase()) ||
          sublocality.toLowerCase().contains(p.toLowerCase()),
    );
    if (!alreadyExists) {
      rawParts.add(sublocality);
    }
  }

  // Add locality / city if not already included
  final cityPart = locality.isNotEmpty ? locality : admin2;
  if (cityPart.isNotEmpty) {
    final alreadyExists = rawParts.any(
      (p) => p.toLowerCase().contains(cityPart.toLowerCase()),
    );
    if (!alreadyExists) {
      rawParts.add(cityPart);
    }
  }

  // Clean every part and deduplicate
  final cleanedParts = <String>[];
  for (final part in rawParts) {
    final cleaned = cleanAddressString(part);
    if (cleaned.isNotEmpty &&
        !cleanedParts.any((p) => p.toLowerCase() == cleaned.toLowerCase())) {
      cleanedParts.add(cleaned);
    }
  }

  return cleanedParts.join(', ');
}

/// Returns every plausible city name from address components.
List<String> extractCityCandidates(List<dynamic> components) {
  const cityTypes = [
    'locality',
    'administrative_area_level_2',
    'sublocality',
    'sublocality_level_1',
  ];
  final seen = <String>{};
  final result = <String>[];
  for (final type in cityTypes) {
    final val = cleanAddressString(_component(components, [type]));
    if (val.isNotEmpty && seen.add(val.toLowerCase())) result.add(val);
  }
  return result;
}

String _component(List<dynamic> components, List<String> types) {
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

// ─── UI helpers ──────────────────────────────────────────────────────────────

/// Builds a label text with a red asterisk suffix.
Widget buildAsteriskText(String text, {TextStyle? style}) {
  return RichText(
    text: TextSpan(
      text: text,
      style: style ??
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      children: const [
        TextSpan(
          text: ' *',
          style: TextStyle(color: Colors.red),
        ),
      ],
    ),
  );
}
