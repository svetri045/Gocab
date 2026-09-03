import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/admin_booking_service.dart';
import '../services/admin_session.dart';
import '../widgets/admin_nav_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await AdminSession.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const AdminNavBar(current: '/dashboard'),
          Expanded(
            child: StreamBuilder<List<Booking>>(
              stream: AdminBookingService.watchAllBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final bookings = snapshot.data ?? [];
                final requested = bookings.where((b) => b.status == 'requested').length;
                final active = bookings
                    .where((b) => ['confirmed', 'arrived', 'ongoing'].contains(b.status))
                    .length;
                final completed = bookings.where((b) => b.status == 'completed').length;
                final cancelled = bookings.where((b) => b.status == 'cancelled').length;
                final totalRevenue = bookings
                    .where((b) => b.status == 'completed')
                    .fold<double>(0, (sum, b) => sum + b.fareValue);

                final uniqueRiders = bookings.map((b) => b.riderId).toSet().length;
                final uniqueDrivers =
                    bookings.where((b) => b.driverId != null).map((b) => b.driverId).toSet().length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          _statCard('Total bookings', '${bookings.length}', Icons.receipt_long, AppColors.dark),
                          _statCard('Waiting for driver', '$requested', Icons.hourglass_empty, AppColors.info),
                          _statCard('Active rides', '$active', Icons.local_taxi, AppColors.primary),
                          _statCard('Completed', '$completed', Icons.check_circle, AppColors.success),
                          _statCard('Cancelled', '$cancelled', Icons.cancel, AppColors.danger),
                          _statCard('Revenue (completed)', '₹${totalRevenue.toStringAsFixed(0)}',
                              Icons.currency_rupee, AppColors.dark),
                          _statCard('Unique riders', '$uniqueRiders', Icons.people_outline, AppColors.info),
                          _statCard('Unique drivers', '$uniqueDrivers', Icons.badge_outlined, AppColors.info),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text('Recent bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...bookings.take(5).map((b) => _recentRow(b)),
                      if (bookings.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No bookings yet', style: TextStyle(color: AppColors.grey)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _recentRow(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(b.riderName, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Text('${b.pickupAddress} → ${b.dropAddress}',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.grey)),
          ),
          Expanded(
            child: Text(b.status, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
