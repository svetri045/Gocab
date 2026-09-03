import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'services/rider_session.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/select_location_screen.dart';
import 'screens/choose_ride_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/ride_history_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RiderSession.load();
  runApp(const GoCabApp());
}

class GoCabApp extends StatelessWidget {
  const GoCabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoCab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: RiderSession.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/select-location': (context) => const SelectLocationScreen(),
        '/choose-ride': (context) => const ChooseRideScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/history': (context) => const RideHistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}