import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rider_session.dart';

/// Wraps Firebase Authentication (Email/Password) for the rider app.
///
/// A rider MUST register (create an account) before they can log in.
/// Trying to log in with an email that has no account throws
/// `user-not-found` — there is no "log in creates an account" fallback,
/// exactly as requested.
class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Creates a brand-new account. Throws `email-already-in-use` if this
  /// email is already registered.
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

    // Also keep a profile doc in Firestore — handy for the admin panel
    // and any future features that need more than just name/email.
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    RiderSession.syncFromUser(_auth.currentUser!);
  }

  /// Signs in an existing account only. Throws if no account exists for
  /// this email, or if the password is wrong.
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
    RiderSession.syncFromUser(user);
  }

  /// Turns Firebase's error codes into rider-friendly messages.
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