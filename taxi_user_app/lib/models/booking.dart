import 'package:cloud_firestore/cloud_firestore.dart';

/// Same `bookings` collection the driver app reads/writes.
/// `riderId` links a booking to the rider who made it (for ride history).
class Booking {
  final String? id;
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
  final String status; // requested, confirmed, arrived, ongoing, completed, cancelled
  final String? driverName;
  final DateTime? createdAt;

  Booking({
    this.id,
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
    this.status = 'requested',
    this.driverName,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'riderId': riderId,
      'riderName': riderName,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropAddress': dropAddress,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'rideType': rideType,
      'fare': fare,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Booking(
      id: doc.id,
      riderId: d['riderId'] ?? '',
      riderName: d['riderName'] ?? '',
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
      driverName: d['driverName'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
