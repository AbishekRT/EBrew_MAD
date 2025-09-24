import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Authentication provider managing login state and user data
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  /// Initialize authentication state from persistent storage
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        final userJson = prefs.getString('userData');
        if (userJson != null) {
          // In a real app, you'd parse the JSON properly
          _user = User(
            id: prefs.getString('userId') ?? '1',
            name: prefs.getString('userName') ?? 'Guest User',
            email: prefs.getString('userEmail') ?? 'guest@ebrew.com',
            createdAt: DateTime.now(),
          );
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation - in real app, this would be API call
      if (email.isNotEmpty && password.length >= 6) {
        _user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: email.split('@')[0].toUpperCase(),
          email: email,
          createdAt: DateTime.now(),
        );
        _isLoggedIn = true;

        // Save to persistent storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _user!.id);
        await prefs.setString('userName', _user!.name);
        await prefs.setString('userEmail', _user!.email);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Register new user
  Future<bool> register(
    String name,
    String email,
    String password,
    DateTime? birthday,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        _user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          birthday: birthday,
          createdAt: DateTime.now(),
        );
        _isLoggedIn = true;

        // Save to persistent storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _user!.id);
        await prefs.setString('userName', _user!.name);
        await prefs.setString('userEmail', _user!.email);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear persistent storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userId');
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      await prefs.remove('userData');

      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
