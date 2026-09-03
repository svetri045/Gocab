import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/driver_session.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    _resumeActiveRideIfAny();
  }

  Future<void> _resumeActiveRideIfAny() async {
    final driverId = DriverSession.driverId;
    if (driverId == null) return;
    final booking = await BookingService.watchActiveBookingForDriver(driverId).first;
    if (booking != null && mounted) {
      Navigator.pushReplacementNamed(context, '/active-ride', arguments: booking.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${DriverSession.driverName ?? 'Driver'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await DriverSession.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Booking>>(
        stream: BookingService.watchPendingBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text('No ride requests right now', style: TextStyle(color: AppColors.grey)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final o = orders[i];
              return InkWell(
                onTap: () => Navigator.pushNamed(context, '/order-detail', arguments: o.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(o.rideType,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Text(o.fare,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 10, color: AppColors.success),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(o.pickupAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(o.dropAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}