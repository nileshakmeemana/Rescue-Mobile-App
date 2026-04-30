import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _i = LocationService._();
  factory LocationService() => _i;
  LocationService._();

  /// Request permission and get current position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Reverse geocode a position to a readable address
  Future<String> getAddressFromPosition(Position pos) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isEmpty) return '${pos.latitude}, ${pos.longitude}';
      final p = placemarks.first;
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
      ].where((s) => s != null && s.isNotEmpty).toList();
      return parts.join(', ');
    } catch (_) {
      return '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    }
  }

  /// Reverse geocode by latitude/longitude
  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return '\$latitude, \\$longitude';
      final p = placemarks.first;
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
      ].where((s) => s != null && s.isNotEmpty).toList();
      return parts.join(', ');
    } catch (_) {
      return '\$latitude.toStringAsFixed(4), \\$longitude.toStringAsFixed(4)';
    }
  }

  /// Get human-readable region from address string
  String matchRegion(String address) {
    final l = address.toLowerCase();
    if (l.contains('galle')) return 'Galle';
    if (l.contains('kandy')) return 'Kandy';
    if (l.contains('maharagama') ||
        l.contains('kalubowila') ||
        l.contains('katuwawala') ||
        l.contains('nugegoda')) return 'Maharagama';
    return 'Colombo';
  }
}