import 'package:shared_preferences/shared_preferences.dart';

/// Simple hardcoded admin login. Fine for an internal ops tool used by a
/// small trusted team — replace with Firebase Auth + an `admins` collection
/// check before exposing this panel more broadly.
class AdminSession {
  static const String _validUsername = 'admin';
  static const String _validPassword = 'admin123';

  static bool isLoggedIn = false;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('adminLoggedIn') ?? false;
  }

  static Future<bool> login(String username, String password) async {
    if (username.trim() == _validUsername && password == _validPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('adminLoggedIn', true);
      isLoggedIn = true;
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adminLoggedIn', false);
    isLoggedIn = false;
  }
}
