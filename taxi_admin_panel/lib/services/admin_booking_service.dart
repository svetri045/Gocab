import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

/// Reads/writes the SAME `bookings` collection the rider and driver apps use.
///
/// Deliberately fetches ALL bookings ordered by `createdAt` (a single-field
/// query — Firestore indexes that automatically, no composite index needed)
/// and does status filtering/counting on the client. This keeps the admin
/// panel index-free; if your booking volume grows into the thousands you'll
/// want server-side filtering + pagination instead.
class AdminBookingService {
  static final CollectionReference<Map<String, dynamic>> _bookings =
      FirebaseFirestore.instance.collection('bookings');

  /// Live stream of every booking, most recent first.
  static Stream<List<Booking>> watchAllBookings() {
    return _bookings
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromDoc(d)).toList());
  }

  static Stream<Booking?> watchBooking(String bookingId) {
    return _bookings.doc(bookingId).snapshots().map(
          (doc) => doc.exists ? Booking.fromDoc(doc) : null,
        );
  }

  /// Admin manually moves a booking to a different status
  /// (e.g. force-cancel, or nudge a stuck ride to "completed").
  static Future<void> updateStatus(String bookingId, String status) {
    return _bookings.doc(bookingId).update({'status': status});
  }

  static Future<void> cancelBooking(String bookingId) {
    return updateStatus(bookingId, 'cancelled');
  }

  /// Permanently deletes a booking record — use carefully.
  static Future<void> deleteBooking(String bookingId) {
    return _bookings.doc(bookingId).delete();
  }
}
