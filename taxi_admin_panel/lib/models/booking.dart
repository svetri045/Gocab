import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the same `bookings` collection used by the rider and driver apps.
class Booking {
  final String id;
  final String riderId;
  final String riderName;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final String rideType;
  final String fare;
  final String paymentMethod;
  final String status;
  final String? driverId;
  final String? driverName;
  final double? driverLat;
  final double? driverLng;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.riderId,
    required this.riderName,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.rideType,
    required this.fare,
    required this.paymentMethod,
    required this.status,
    this.driverId,
    this.driverName,
    this.driverLat,
    this.driverLng,
    this.createdAt,
  });

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Booking(
      id: doc.id,
      riderId: d['riderId'] ?? '',
      riderName: d['riderName'] ?? 'Unknown rider',
      pickupAddress: d['pickupAddress'] ?? '',
      pickupLat: (d['pickupLat'] as num?)?.toDouble() ?? 0,
      pickupLng: (d['pickupLng'] as num?)?.toDouble() ?? 0,
      dropAddress: d['dropAddress'] ?? '',
      dropLat: (d['dropLat'] as num?)?.toDouble() ?? 0,
      dropLng: (d['dropLng'] as num?)?.toDouble() ?? 0,
      rideType: d['rideType'] ?? '',
      fare: d['fare'] ?? '',
      paymentMethod: d['paymentMethod'] ?? '',
      status: d['status'] ?? 'requested',
      driverId: d['driverId'],
      driverName: d['driverName'],
      driverLat: (d['driverLat'] as num?)?.toDouble(),
      driverLng: (d['driverLng'] as num?)?.toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Parses the fare string ("₹149") into a number for totals — best effort.
  double get fareValue {
    final digits = fare.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0;
  }
}
