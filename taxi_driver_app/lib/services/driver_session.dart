import 'package:firebase_auth/firebase_auth.dart';

/// Backed by real Firebase Authentication (Email/Password).
/// driverId = the Firebase Auth UID. driverName = display name set at signup.
///
/// Firebase Auth persists the signed-in session on-device automatically,
/// so `load()` just reads whatever session is already active.
class DriverSession {
  static String? driverId;
  static String? driverName;
  static String? driverEmail;

  static Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser;
    driverId = user?.uid;
    driverName = user?.displayName;
    driverEmail = user?.email;
  }

  static void syncFromUser(User user) {
    driverId = user.uid;
    driverName = user.displayName;
    driverEmail = user.email;
  }

  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    driverId = null;
    driverName = null;
    driverEmail = null;
  }
}