import 'dart:convert';
import 'dart:io';
import 'package:geocoding/geocoding.dart';

class GetAddressUseCase {
  Future<String> execute(double latitude, double longitude) async {
    try {
      // First try using the native Geocoding package
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
          place.country,
        ];
        
        final validParts = parts
            .where((part) => part != null && part.isNotEmpty && part != 'null')
            .toList();
            
        if (validParts.isNotEmpty) {
          return validParts.join(', ');
        }
      }
    } catch (e) {
      // Ignore native geocoding errors (like MissingPluginException or No Play Services)
      // and fall back to Nominatim API below
    }

    // Fallback to OpenStreetMap Nominatim API if native fails
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1');
      
      final client = HttpClient();
      final request = await client.getUrl(url);
      request.headers.set('User-Agent', 'CardriverApp/1.0');
      
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final data = jsonDecode(stringData);
        
        if (data != null && data['address'] != null) {
          final addressMap = data['address'] as Map<String, dynamic>;
          final road = addressMap['road'] ?? addressMap['pedestrian'] ?? addressMap['suburb'];
          final city = addressMap['city'] ?? addressMap['town'] ?? addressMap['village'] ?? addressMap['county'];
          final state = addressMap['state'];
          final postcode = addressMap['postcode'];
          final country = addressMap['country'];

          final parts = [road, city, state, postcode, country];
          final validParts = parts
              .where((part) => part != null && part.toString().isNotEmpty)
              .toList();
              
          if (validParts.isNotEmpty) {
            return validParts.join(', ');
          }
        }
      }
    } catch (e) {
      // Return a basic fallback if both fail
    }

    // Ultimate fallback if both Native Geocoder and Nominatim fail
    return 'Location (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
  }
}
