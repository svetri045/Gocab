import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

/// Shown right after booking. Live-updates as the driver app changes the
/// booking's status: requested -> confirmed -> arrived -> ongoing -> completed.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String? _bookingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookingId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'requested':
        return 'Looking for a driver...';
      case 'confirmed':
        return 'Driver is on the way';
      case 'arrived':
        return 'Driver has arrived';
      case 'ongoing':
        return 'Trip in progress';
      case 'completed':
        return 'Ride completed';
      case 'cancelled':
        return 'Ride cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = _bookingId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride status'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
            child: const Text('Home'),
          ),
        ],
      ),
      body: bookingId == null
          ? const Center(child: Text('No booking found.'))
          : StreamBuilder<Booking?>(
              stream: BookingService.watchBooking(bookingId),
              builder: (context, snapshot) {
                final booking = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_taxi, color: AppColors.dark),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                booking == null ? 'Loading...' : _statusLabel(booking.status),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Text('Booking ID', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                            const Spacer(),
                            Text(bookingId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (booking != null) ...[
                        _row('Pickup', booking.pickupAddress),
                        _row('Drop', booking.dropAddress),
                        _row('Ride', booking.rideType),
                        _row('Fare', booking.fare),
                        _row('Payment', booking.paymentMethod),
                        if (booking.driverName != null) _row('Driver', booking.driverName!),
                      ] else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
