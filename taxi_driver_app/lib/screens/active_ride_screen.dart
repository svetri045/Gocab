import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/location_service.dart';

class ActiveRideScreen extends StatefulWidget {
  const ActiveRideScreen({super.key});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  String? _bookingId;
  StreamSubscription? _locationSub;
  bool _updating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bookingId == null) {
      _bookingId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_bookingId != null) _startSharingLocation(_bookingId!);
    }
  }

  void _startSharingLocation(String bookingId) {
    // Pushes the driver's live GPS position onto the booking doc every time
    // it changes, so the rider's tracking screen can show it moving.
    _locationSub = LocationService.watchPosition().listen((pos) {
      BookingService.updateDriverLocation(bookingId, pos.latitude, pos.longitude);
    });
  }

  Future<void> _advanceStatus(String bookingId, String nextStatus) async {
    setState(() => _updating = true);
    await BookingService.updateStatus(bookingId, nextStatus);
    if (!mounted) return;
    setState(() => _updating = false);
    if (nextStatus == 'completed') {
      _locationSub?.cancel();
      Navigator.pushReplacementNamed(context, '/orders');
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = _bookingId;
    return Scaffold(
      appBar: AppBar(title: const Text('Active ride')),
      body: bookingId == null
          ? const Center(child: Text('No active ride.'))
          : StreamBuilder<Booking?>(
              stream: BookingService.watchBooking(bookingId),
              builder: (context, snapshot) {
                final booking = snapshot.data;
                if (booking == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Status: ${booking.status}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _row('Pickup', booking.pickupAddress),
                      _row('Drop', booking.dropAddress),
                      _row('Fare', booking.fare),
                      _row('Payment', booking.paymentMethod),
                      const Spacer(),
                      _actionButton(booking),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: AppColors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _actionButton(Booking booking) {
    late String label;
    late String next;
    switch (booking.status) {
      case 'confirmed':
        label = 'Arrived at pickup';
        next = 'arrived';
        break;
      case 'arrived':
        label = 'Start trip';
        next = 'ongoing';
        break;
      case 'ongoing':
        label = 'Complete ride';
        next = 'completed';
        break;
      default:
        return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: _updating ? null : () => _advanceStatus(booking.id, next),
      child: _updating
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(label),
    );
  }
}
