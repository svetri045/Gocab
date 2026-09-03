import 'package:firebase_auth/firebase_auth.dart';

/// Backed by real Firebase Authentication (Email/Password).
/// riderId = the Firebase Auth UID (stable, unique per account).
/// riderName = the display name set at registration.
///
/// Firebase Auth persists the signed-in session on-device automatically,
/// so `load()` just reads whatever session is already active — no manual
/// storage needed like the old SharedPreferences version.
class RiderSession {
  static String? riderId;
  static String? riderName;
  static String? riderEmail;

  /// Call once at startup.
  static Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser;
    riderId = user?.uid;
    riderName = user?.displayName;
    riderEmail = user?.email;
  }

  /// Called right after a successful register/login to refresh the cached
  /// fields from the just-signed-in user.
  static void syncFromUser(User user) {
    riderId = user.uid;
    riderName = user.displayName;
    riderEmail = user.email;
  }

  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    riderId = null;
    riderName = null;
    riderEmail = null;
  }
}