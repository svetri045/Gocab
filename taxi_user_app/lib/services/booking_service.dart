import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

/// Reads/writes the SAME `bookings` collection the driver app uses.
class BookingService {
  static final CollectionReference<Map<String, dynamic>> _bookings =
      FirebaseFirestore.instance.collection('bookings');

  /// Creates a new booking and returns the real, Firestore-generated
  /// document ID — this is the booking ID shown to the rider.
  static Future<String> createBooking(Booking booking) async {
    final docRef = await _bookings.add(booking.toMap());
    return docRef.id;
  }

  /// Live updates for one booking — status, driver info, etc.
  static Stream<Booking?> watchBooking(String bookingId) {
    return _bookings.doc(bookingId).snapshots().map(
          (doc) => doc.exists ? Booking.fromDoc(doc) : null,
        );
  }

  /// Real ride history — every booking this rider has made, most recent first.
  static Stream<List<Booking>> watchMyBookings(String riderId) {
    return _bookings
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromDoc(d)).toList());
  }

  static Future<void> cancelBooking(String bookingId) {
    return _bookings.doc(bookingId).update({'status': 'cancelled'});
  }
}
