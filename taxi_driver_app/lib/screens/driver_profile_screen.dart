import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/driver_session.dart';

/// Driver's profile — name/email from Firebase Auth, ride stats computed
/// live from their bookings in Firestore.
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = DriverSession.driverId;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.background,
                  child: Icon(Icons.local_taxi, size: 40, color: AppColors.dark),
                ),
                const SizedBox(height: 12),
                Text(
                  DriverSession.driverName ?? 'Driver',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  DriverSession.driverEmail ?? '',
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (driverId == null)
            const Center(child: Text('Not logged in.'))
          else
            StreamBuilder<List<Booking>>(
              stream: BookingService.watchBookingsForDriver(driverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data ?? [];
                final completed = bookings.where((b) => b.status == 'completed').toList();
                final cancelled = bookings.where((b) => b.status == 'cancelled').length;
                final totalEarnings = completed.fold<double>(0, (sum, b) => sum + b.fareValue);

                return Column(
                  children: [
                    _infoCard([
                      _infoRow(Icons.check_circle_outline, 'Completed rides', '${completed.length}'),
                      _infoRow(Icons.cancel_outlined, 'Cancelled rides', '$cancelled'),
                      _infoRow(Icons.receipt_long_outlined, 'Total rides', '${bookings.length}'),
                    ]),
                    const SizedBox(height: 16),
                    _infoCard([
                      _infoRow(Icons.currency_rupee, 'Total earnings', '₹${totalEarnings.toStringAsFixed(0)}'),
                      _infoRow(Icons.star_outline, 'Rating', '4.8 ★'),
                    ]),
                  ],
                );
              },
            ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              await DriverSession.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.dark),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}