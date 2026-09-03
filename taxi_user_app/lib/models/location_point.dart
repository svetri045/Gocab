/// A fixed, hand-picked location the rider can choose as pickup or drop.
/// No Places/Maps API involved — this is just a plain list you edit yourself.
class LocationPoint {
  final String name;
  final String address;
  final double lat;
  final double lng;

  const LocationPoint({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}
