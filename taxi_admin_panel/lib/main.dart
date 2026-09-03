import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'services/admin_session.dart';
import 'screens/admin_login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/bookings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AdminSession.load();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoCab Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AdminSession.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/bookings': (context) => const BookingsScreen(),
      },
    );
  }
}
