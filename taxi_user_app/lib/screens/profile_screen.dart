import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/rider_session.dart';

/// Profile screen with hardcoded display data (as requested) — the name/phone
/// fields at the top pull from the local session, everything below is static.
/// Wire this up to real Firestore user data later if needed.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: Icon(Icons.person, size: 44, color: AppColors.dark),
                ),
                const SizedBox(height: 12),
                Text(
                  RiderSession.riderName ?? 'Guest Rider',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  RiderSession.riderEmail ?? 'guest@example.com',
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _infoCard([
            _infoRow(Icons.star, 'Rating', '4.8 ★'),
            _infoRow(Icons.email_outlined, 'Email', 'rider@example.com'),
            _infoRow(Icons.card_membership, 'Member since', 'Jan 2025'),
          ]),
          const SizedBox(height: 16),
          _infoCard([
            _infoRow(Icons.local_taxi, 'Total rides', '42'),
            _infoRow(Icons.savings_outlined, 'Wallet balance', '₹1,250'),
          ]),
          const SizedBox(height: 16),
          _menuTile(context, Icons.history, 'Ride history', '/history'),
          _menuTile(context, Icons.payment, 'Payment methods', null),
          _menuTile(context, Icons.help_outline, 'Help & support', null),
          _menuTile(context, Icons.settings_outlined, 'Settings', null),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              await RiderSession.logout();
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

  Widget _menuTile(BuildContext context, IconData icon, String label, String? route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dark),
      title: Text(label),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: route == null ? null : () => Navigator.pushNamed(context, route),
    );
  }
}