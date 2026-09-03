import 'package:geolocator/geolocator.dart';

/// GPS permission handling + a live position stream used to push the
/// driver's location onto the active booking so the rider can see it.
class LocationService {
  static Future<void> ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException('Please turn on device location (GPS).');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission permanently denied. Enable it from app settings.',
      );
    }
  }

  static Future<Position> getCurrentPosition() async {
    await ensureLocationReady();
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Live stream of the driver's position, checked for permission first.
  static Stream<Position> watchPosition() async* {
    await ensureLocationReady();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15, // meters between updates
    );
    yield* Geolocator.getPositionStream(locationSettings: settings);
  }
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => message;
}
