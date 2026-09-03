// TODO Implement this library.import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'driver_session.dart';

/// Wraps Firebase Authentication (Email/Password) for the driver app.
/// A driver MUST register before they can log in — no silent account
/// creation on login.
class DriverAuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Account creation failed.');

    await user.updateDisplayName(name.trim());
    await user.reload();

    // Separate `drivers` collection (distinct from the rider app's `users`
    // collection) — useful later for the admin panel to list/verify drivers.
    await FirebaseFirestore.instance.collection('drivers').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    DriverSession.syncFromUser(_auth.currentUser!);
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Login failed.');
    DriverSession.syncFromUser(user);
  }

  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email. Please register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Please log in instead.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}