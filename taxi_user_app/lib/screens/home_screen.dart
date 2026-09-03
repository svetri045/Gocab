import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/location_point.dart';
import '../services/rider_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationPoint? _pickup;
  LocationPoint? _drop;

  Future<void> _pickLocation(bool isPickup) async {
    final result = await Navigator.pushNamed(
      context,
      '/select-location',
      arguments: isPickup ? 'Select pickup point' : 'Select drop point',
    );
    if (result is LocationPoint) {
      setState(() {
        if (isPickup) {
          _pickup = result;
        } else {
          _drop = result;
        }
      });
    }
  }

  void _findRides() {
    if (_pickup == null || _drop == null) return;
    Navigator.pushNamed(
      context,
      '/choose-ride',
      arguments: {'pickup': _pickup, 'drop': _drop},
    );
  }

  @override
  Widget build(BuildContext context) {
    final canFindRides = _pickup != null && _drop != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, ${RiderSession.riderName ?? 'Rider'} 👋',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history),
                        onPressed: () => Navigator.pushNamed(context, '/history'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Where to?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _locationTile(
                icon: Icons.circle,
                iconColor: AppColors.success,
                label: 'Pickup',
                value: _pickup?.name ?? 'Select pickup point',
                onTap: () => _pickLocation(true),
              ),
              const SizedBox(height: 12),
              _locationTile(
                icon: Icons.location_on,
                iconColor: AppColors.danger,
                label: 'Drop',
                value: _drop?.name ?? 'Select drop point',
                onTap: () => _pickLocation(false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: canFindRides ? _findRides : null,
                child: const Text('Find rides'),
              ),
              const SizedBox(height: 28),
              const Text('Quick access', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _quickAction(Icons.history, 'Ride history', () => Navigator.pushNamed(context, '/history')),
                  const SizedBox(width: 12),
                  _quickAction(Icons.person_outline, 'Profile', () => Navigator.pushNamed(context, '/profile')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.dark),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
