import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_database_service.dart';

/// Authentication provider managing login state and user data with SQLite
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  final UserDatabaseService _userDb = UserDatabaseService();

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize authentication state from persistent storage
  Future<void> initAuth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('currentUserId');

      if (userId != null) {
        // Load user from database
        final user = await _userDb.getUserById(userId);
        if (user != null) {
          _user = user;
          _isLoggedIn = true;
        } else {
          // User not found in database, clear preferences
          await prefs.remove('currentUserId');
        }
      }
    } catch (e) {
      _error = 'Failed to initialize authentication';
      debugPrint('Error initializing auth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate input
      if (email.isEmpty) {
        _error = 'Email is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!UserDatabaseService.isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.isEmpty) {
        _error = 'Password is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Authenticate with database
      final user = await _userDb.loginUser(email: email, password: password);

      if (user != null) {
        _user = user;
        _isLoggedIn = true;

        // Save user ID to persistent storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', user.id);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
      }
    } catch (e) {
      _error = 'Login failed. Please try again.';
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
    _error = null;
    notifyListeners();

    try {
      // Validate input
      if (name.trim().isEmpty) {
        _error = 'Name is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (email.isEmpty) {
        _error = 'Email is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!UserDatabaseService.isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!UserDatabaseService.isValidPassword(password)) {
        _error = UserDatabaseService.getPasswordStrengthMessage(password);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if email already exists
      if (await _userDb.emailExists(email)) {
        _error =
            'Email is already registered. Please use a different email or login.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Register user in database
      final user = await _userDb.registerUser(
        name: name.trim(),
        email: email,
        password: password,
        birthday: birthday,
      );

      if (user != null) {
        _user = user;
        _isLoggedIn = true;

        // Save user ID to persistent storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', user.id);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed. Please try again.';
      }
    } catch (e) {
      if (e.toString().contains('Email already registered')) {
        _error =
            'Email is already registered. Please use a different email or login.';
      } else {
        _error = 'Registration failed. Please try again.';
      }
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
      await prefs.remove('currentUserId');

      _user = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    DateTime? birthday,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userDb.updateUser(
        userId: _user!.id,
        name: name,
        email: email,
        birthday: birthday,
      );

      if (success) {
        // Refresh user data
        final updatedUser = await _userDb.getUserById(_user!.id);
        if (updatedUser != null) {
          _user = updatedUser;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update profile';
      }
    } catch (e) {
      _error = 'Failed to update profile';
      debugPrint('Update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!UserDatabaseService.isValidPassword(newPassword)) {
        _error = UserDatabaseService.getPasswordStrengthMessage(newPassword);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _userDb.changePassword(
        userId: _user!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Current password is incorrect';
      }
    } catch (e) {
      _error = 'Failed to change password';
      debugPrint('Change password error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
