import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/location_point.dart';
import '../models/ride_option.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/rider_session.dart';

class ChooseRideScreen extends StatefulWidget {
  const ChooseRideScreen({super.key});

  @override
  State<ChooseRideScreen> createState() => _ChooseRideScreenState();
}

class _ChooseRideScreenState extends State<ChooseRideScreen> {
  int _selected = 0;
  String _payment = 'Cash';
  bool _booking = false;
  String? _error;
  Map<String, dynamic>? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args ??= ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  Future<void> _bookRide() async {
    final args = _args;
    final pickup = args?['pickup'] as LocationPoint?;
    final drop = args?['drop'] as LocationPoint?;
    if (pickup == null || drop == null) {
      setState(() => _error = 'Pickup/drop missing.');
      return;
    }

    final riderId = RiderSession.riderId;
    final riderName = RiderSession.riderName;
    if (riderId == null || riderName == null) {
      setState(() => _error = 'Please log in again.');
      return;
    }

    setState(() {
      _booking = true;
      _error = null;
    });

    try {
      final option = rideOptions[_selected];
      final booking = Booking(
        riderId: riderId,
        riderName: riderName,
        pickupAddress: pickup.name,
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        dropAddress: drop.name,
        dropLat: drop.lat,
        dropLng: drop.lng,
        rideType: option.name,
        fare: option.price,
        paymentMethod: _payment,
      );

      // Real write to Firestore — returns the real, auto-generated booking ID.
      final bookingId = await BookingService.createBooking(booking);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/tracking', arguments: bookingId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Booking failed: $e';
        _booking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = _args?['pickup'] as LocationPoint?;
    final drop = _args?['drop'] as LocationPoint?;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a ride')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pickup != null && drop != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.circle, size: 10, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(pickup.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(child: Text(drop.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: rideOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final option = rideOptions[i];
                  final selected = _selected == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? AppColors.primary : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.background,
                            child: Icon(option.icon, color: AppColors.dark),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(option.description, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                                Text('${option.eta} away', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(option.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _showPaymentSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: AppColors.dark),
                    const SizedBox(width: 10),
                    Text(_payment, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _booking ? null : _bookRide,
              child: _booking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Book ${rideOptions[_selected].name}'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final options = ['Cash', 'UPI', 'Card', 'Wallet'];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...options.map((o) => RadioListTile<String>(
                    value: o,
                    groupValue: _payment,
                    title: Text(o),
                    onChanged: (val) {
                      setState(() => _payment = val!);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}
