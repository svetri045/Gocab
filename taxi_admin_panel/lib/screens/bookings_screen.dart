import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/booking.dart';
import '../services/admin_booking_service.dart';
import '../services/admin_session.dart';
import '../widgets/admin_nav_bar.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _filter = 'all';
  String _search = '';

  static const _statuses = ['all', 'requested', 'confirmed', 'arrived', 'ongoing', 'completed', 'cancelled'];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('All bookings'),
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
          const AdminNavBar(current: '/bookings'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search by rider, driver, pickup or drop...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _statuses.map((s) {
                final selected = _filter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s == 'all' ? 'All' : s),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = s),
                    selectedColor: AppColors.dark,
                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.dark),
                    backgroundColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
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
                var bookings = snapshot.data ?? [];
                if (_filter != 'all') {
                  bookings = bookings.where((b) => b.status == _filter).toList();
                }
                if (_search.isNotEmpty) {
                  bookings = bookings.where((b) {
                    return b.riderName.toLowerCase().contains(_search) ||
                        (b.driverName ?? '').toLowerCase().contains(_search) ||
                        b.pickupAddress.toLowerCase().contains(_search) ||
                        b.dropAddress.toLowerCase().contains(_search);
                  }).toList();
                }
                if (bookings.isEmpty) {
                  return const Center(child: Text('No bookings match.', style: TextStyle(color: AppColors.grey)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final b = bookings[i];
                    return InkWell(
                      onTap: () => _showDetail(context, b),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.riderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(b.driverName ?? 'No driver yet',
                                      style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${b.pickupAddress} → ${b.dropAddress}',
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(
                                    b.createdAt != null
                                        ? DateFormat('dd MMM, hh:mm a').format(b.createdAt!)
                                        : '',
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(b.fare, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _statusColor(b.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                b.status,
                                style: TextStyle(color: _statusColor(b.status), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Booking b) {
    showDialog(
      context: context,
      builder: (context) => _BookingDetailDialog(booking: b),
    );
  }
}

class _BookingDetailDialog extends StatefulWidget {
  final Booking booking;
  const _BookingDetailDialog({required this.booking});

  @override
  State<_BookingDetailDialog> createState() => _BookingDetailDialogState();
}

class _BookingDetailDialogState extends State<_BookingDetailDialog> {
  bool _updating = false;

  static const _statusOptions = ['requested', 'confirmed', 'arrived', 'ongoing', 'completed', 'cancelled'];

  Future<void> _setStatus(String status) async {
    setState(() => _updating = true);
    await AdminBookingService.updateStatus(widget.booking.id, status);
    if (mounted) setState(() => _updating = false);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return AlertDialog(
      title: Text('Booking ${b.id.substring(0, 8)}...'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Rider', '${b.riderName} (${b.riderId})'),
            _row('Driver', b.driverName ?? 'Not assigned'),
            _row('Pickup', b.pickupAddress),
            _row('Drop', b.dropAddress),
            _row('Ride type', b.rideType),
            _row('Fare', b.fare),
            _row('Payment', b.paymentMethod),
            _row('Created', b.createdAt?.toString() ?? '-'),
            const SizedBox(height: 14),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions.map((s) {
                final active = b.status == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: active,
                  onSelected: _updating ? null : (_) => _setStatus(s),
                );
              }).toList(),
            ),
            if (_updating) const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
