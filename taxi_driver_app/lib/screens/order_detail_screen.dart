import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/driver_session.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? _bookingId;
  bool _accepting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookingId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _accept(Booking booking) async {
    final driverId = DriverSession.driverId;
    final driverName = DriverSession.driverName;
    if (driverId == null || driverName == null) return;

    setState(() => _accepting = true);
    final success = await BookingService.acceptBooking(
      bookingId: booking.id,
      driverId: driverId,
      driverName: driverName,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/active-ride', arguments: booking.id);
    } else {
      setState(() => _accepting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Too late — another driver already accepted this ride.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = _bookingId;
    return Scaffold(
      appBar: AppBar(title: const Text('Ride request')),
      body: bookingId == null
          ? const Center(child: Text('No booking selected.'))
          : StreamBuilder<Booking?>(
              stream: BookingService.watchBooking(bookingId),
              builder: (context, snapshot) {
                final booking = snapshot.data;
                if (booking == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (booking.status != 'requested') {
                  return const Center(child: Text('This ride is no longer available.'));
                }
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.rideType,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        booking.fare,
                        style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _addressTile(Icons.circle, AppColors.success, 'Pickup', booking.pickupAddress),
                      const SizedBox(height: 14),
                      _addressTile(Icons.location_on, AppColors.danger, 'Drop', booking.dropAddress),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined, color: AppColors.grey),
                          const SizedBox(width: 8),
                          Text('Payment: ${booking.paymentMethod}'),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _accepting ? null : () => Navigator.pop(context),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _accepting ? null : () => _accept(booking),
                              child: _accepting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Accept ride'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _addressTile(IconData icon, Color color, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              Text(address, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
