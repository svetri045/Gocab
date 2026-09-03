import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'services/driver_session.dart';
import 'screens/driver_login_screen.dart';
import 'screens/driver_register_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/active_ride_screen.dart';
import 'screens/driver_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DriverSession.load();
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoCab Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: DriverSession.isLoggedIn ? '/orders' : '/login',
      routes: {
        '/login': (context) => const DriverLoginScreen(),
        '/register': (context) => const DriverRegisterScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/order-detail': (context) => const OrderDetailScreen(),
        '/active-ride': (context) => const ActiveRideScreen(),
        '/profile': (context) => const DriverProfileScreen(),
      },
    );
  }
}