import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/rider_session.dart';

/// Real ride history — every booking this rider has made, live from Firestore.
class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      case 'requested':
        return AppColors.grey;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riderId = RiderSession.riderId;

    return Scaffold(
      appBar: AppBar(title: const Text('Ride history')),
      body: riderId == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<List<Booking>>(
              stream: BookingService.watchMyBookings(riderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final rides = snapshot.data ?? [];
                if (rides.isEmpty) {
                  return const Center(
                    child: Text('No rides yet',
                        style: TextStyle(color: AppColors.grey)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final r = rides[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(r.rideType,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      _statusColor(r.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  r.status,
                                  style: TextStyle(
                                    color: _statusColor(r.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.circle,
                                size: 8, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(r.pickupAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.location_on,
                                size: 10, color: AppColors.danger),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(r.dropAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                r.createdAt != null
                                    ? DateFormat('dd MMM yyyy, hh:mm a')
                                        .format(r.createdAt!)
                                    : '',
                                style: const TextStyle(
                                    color: AppColors.grey, fontSize: 12),
                              ),
                              const Spacer(),
                              Text(r.fare,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
