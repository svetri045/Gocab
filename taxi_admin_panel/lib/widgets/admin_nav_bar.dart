import 'package:flutter/material.dart';
import '../theme.dart';

/// Simple top nav strip shown under the AppBar on every admin screen.
class AdminNavBar extends StatelessWidget {
  final String current;
  const AdminNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _navButton(context, 'Dashboard', '/dashboard', Icons.dashboard_outlined),
          const SizedBox(width: 8),
          _navButton(context, 'Bookings', '/bookings', Icons.receipt_long_outlined),
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, String label, String route, IconData icon) {
    final isActive = current == route;
    return TextButton.icon(
      onPressed: isActive ? null : () => Navigator.pushReplacementNamed(context, route),
      icon: Icon(icon, size: 18, color: isActive ? AppColors.dark : AppColors.grey),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.dark : AppColors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: isActive ? AppColors.background : Colors.transparent,
      ),
    );
  }
}
