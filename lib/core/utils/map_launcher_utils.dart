import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../style/app_colors.dart';

/// Utility to launch Google Maps for directions, navigation, and location coordinates.
/// Handles Android/iOS native Google Maps app deep links and falls back to browser if not installed.
class MapLauncherUtils {
  /// Opens route directions in Google Maps app from pickup to drop location.
  /// If Google Maps app is not installed, it falls back to a web browser or appropriate system map.
  static Future<bool> openDirections({
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    double? dropLat,
    double? dropLng,
    String? dropAddress,
    BuildContext? context,
  }) async {
    final messenger = (context != null && context.mounted)
        ? ScaffoldMessenger.maybeOf(context)
        : null;

    String origin = '';
    if (pickupLat != null &&
        pickupLng != null &&
        pickupLat != 0.0 &&
        pickupLng != 0.0) {
      origin = '$pickupLat,$pickupLng';
    } else if (pickupAddress != null && pickupAddress.trim().isNotEmpty) {
      origin = Uri.encodeComponent(pickupAddress.trim());
    }

    String destination = '';
    if (dropLat != null &&
        dropLng != null &&
        dropLat != 0.0 &&
        dropLng != 0.0) {
      destination = '$dropLat,$dropLng';
    } else if (dropAddress != null && dropAddress.trim().isNotEmpty) {
      destination = Uri.encodeComponent(dropAddress.trim());
    }

    if (origin.isEmpty && destination.isEmpty) {
      _showError(messenger, 'No location coordinates or address available for this ride.');
      return false;
    }

    // Both origin and destination available -> full directions route
    if (origin.isNotEmpty && destination.isNotEmpty) {
      // 1. iOS: Try opening native Google Maps app deep link
      if (!kIsWeb && Platform.isIOS) {
        final iosGoogleMapsUri = Uri.parse(
          'comgooglemaps://?saddr=$origin&daddr=$destination&directionsmode=driving',
        );
        try {
          if (await canLaunchUrl(iosGoogleMapsUri)) {
            final launched = await launchUrl(
              iosGoogleMapsUri,
              mode: LaunchMode.externalApplication,
            );
            if (launched) return true;
          }
        } catch (_) {}

        // iOS Apple Maps fallback
        final appleMapsUri = Uri.parse(
          'https://maps.apple.com/?saddr=$origin&daddr=$destination&dirflg=d',
        );
        try {
          if (await canLaunchUrl(appleMapsUri)) {
            final launched = await launchUrl(
              appleMapsUri,
              mode: LaunchMode.externalApplication,
            );
            if (launched) return true;
          }
        } catch (_) {}
      }

      // 2. Android: Try Google Maps directions intent
      if (!kIsWeb && Platform.isAndroid) {
        final googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving',
        );
        try {
          final launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return true;
        } catch (_) {}

        // Fallback geo intent
        final geoUri = Uri.parse('geo:0,0?q=$destination');
        try {
          if (await canLaunchUrl(geoUri)) {
            final launched = await launchUrl(
              geoUri,
              mode: LaunchMode.externalApplication,
            );
            if (launched) return true;
          }
        } catch (_) {}
      }

      // 3. Universal Web Fallback
      final universalUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving',
      );
      return await _launchWithFallback(universalUri, messenger);
    }

    // Single point fallback
    final target = destination.isNotEmpty ? destination : origin;
    return await openLocationWithMessenger(query: target, messenger: messenger);
  }

  /// Opens a single location query or coordinate in Google Maps
  static Future<bool> openLocation({
    required String query,
    BuildContext? context,
  }) async {
    final messenger = (context != null && context.mounted)
        ? ScaffoldMessenger.maybeOf(context)
        : null;
    return openLocationWithMessenger(query: query, messenger: messenger);
  }

  /// Opens a single location query using ScaffoldMessengerState directly
  static Future<bool> openLocationWithMessenger({
    required String query,
    ScaffoldMessengerState? messenger,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _showError(messenger, 'Location details are not available.');
      return false;
    }

    final encoded = trimmed.contains(',') ? trimmed : Uri.encodeComponent(trimmed);

    // iOS native Google Maps app check
    if (!kIsWeb && Platform.isIOS) {
      final iosUri = Uri.parse('comgooglemaps://?q=$encoded');
      try {
        if (await canLaunchUrl(iosUri)) {
          final launched = await launchUrl(
            iosUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return true;
        }
      } catch (_) {}
    }

    // Android / Universal Search URL
    final searchUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    return await _launchWithFallback(searchUri, messenger);
  }

  /// Handles incoming Google Maps URLs or deep links (e.g. google.navigation, geo, http/https)
  static Future<bool> handleMapUrl(
    String urlString, {
    BuildContext? context,
  }) async {
    final messenger = (context != null && context.mounted)
        ? ScaffoldMessenger.maybeOf(context)
        : null;

    if (urlString.trim().isEmpty) return false;
    final uri = Uri.tryParse(urlString.trim());
    if (uri == null) {
      _showError(messenger, 'Invalid map link.');
      return false;
    }

    if (uri.scheme == 'comgooglemaps' ||
        uri.scheme == 'google.navigation' ||
        uri.scheme == 'geo') {
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return true;
        }
      } catch (_) {}
    }

    return await _launchWithFallback(uri, messenger);
  }

  static Future<bool> _launchWithFallback(
    Uri uri,
    ScaffoldMessengerState? messenger,
  ) async {
    try {
      final launchedApp = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedApp) return true;
    } catch (_) {}

    try {
      final launchedBrowser = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (launchedBrowser) return true;
    } catch (e) {
      _showError(messenger, 'Could not open map: $e');
      return false;
    }

    _showError(messenger, 'Unable to open Google Maps or web browser.');
    return false;
  }

  static void _showError(ScaffoldMessengerState? messenger, String message) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
