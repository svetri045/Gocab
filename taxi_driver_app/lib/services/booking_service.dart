import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

/// Reads/writes the SAME `bookings` collection the rider app writes to.
/// Both apps must point at the same Firebase project (run `flutterfire
/// configure` here and pick the rider app's project) for orders to show up.
class BookingService {
  static final CollectionReference<Map<String, dynamic>> _bookings =
      FirebaseFirestore.instance.collection('bookings');

  /// Live stream of bookings waiting for a driver (status == 'requested').
  /// This is what powers the incoming-orders list.
  static Stream<List<Booking>> watchPendingBookings() {
    return _bookings
        .where('status', isEqualTo: 'requested')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromDoc(d)).toList());
  }

  /// The signed-in driver's current active booking, if any (accepted but
  /// not yet completed). Used to resume an in-progress ride on app restart.
  static Stream<Booking?> watchActiveBookingForDriver(String driverId) {
    return _bookings
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['confirmed', 'arrived', 'ongoing'])
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : Booking.fromDoc(snap.docs.first));
  }

  /// Live updates for one specific booking (status, driver info, etc.).
  static Stream<Booking?> watchBooking(String bookingId) {
    return _bookings.doc(bookingId).snapshots().map(
          (doc) => doc.exists ? Booking.fromDoc(doc) : null,
        );
  }

  /// Driver accepts a ride request. Runs as a Firestore transaction so two
  /// drivers tapping "Accept" on the same order at the same moment can't
  /// both win it — only the first one to commit succeeds.
  static Future<bool> acceptBooking({
    required String bookingId,
    required String driverId,
    required String driverName,
  }) async {
    final docRef = _bookings.doc(bookingId);
    return FirebaseFirestore.instance.runTransaction<bool>((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return false;
      if (snap.data()?['status'] != 'requested') {
        return false; // already taken by another driver
      }
      tx.update(docRef, {
        'status': 'confirmed',
        'driverId': driverId,
        'driverName': driverName,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  /// Moves a booking through its lifecycle: confirmed -> arrived -> ongoing -> completed.
  static Future<void> updateStatus(String bookingId, String status) {
    return _bookings.doc(bookingId).update({'status': status});
  }

  /// All bookings ever assigned to this driver (any status) — used to
  /// compute profile stats like total completed rides and earnings.
  /// No `orderBy` here on purpose, so it doesn't need a composite index.
  static Stream<List<Booking>> watchBookingsForDriver(String driverId) {
    return _bookings
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromDoc(d)).toList());
  }

  /// Pushes the driver's live GPS position onto the booking doc so the
  /// rider app's tracking screen can show it moving in real time.
  static Future<void> updateDriverLocation(String bookingId, double lat, double lng) {
    return _bookings.doc(bookingId).update({'driverLat': lat, 'driverLng': lng});
  }
}