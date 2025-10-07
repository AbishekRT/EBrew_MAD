import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Database service for user authentication and management
/// Uses SQLite for mobile/desktop and SharedPreferences for web
class UserDatabaseService {
  static Database? _database;
  static const String _tableName = 'users';
  static const String _dbName = 'ebrew_users.db';
  static const int _dbVersion = 1;
  static const String _usersKey = 'ebrew_users_data';

  // Singleton instance
  static final UserDatabaseService _instance = UserDatabaseService._internal();
  factory UserDatabaseService() => _instance;
  UserDatabaseService._internal();

  // Check if running on web platform
  bool get _isWeb => kIsWeb;

  /// Get database instance (only for mobile/desktop platforms)
  Future<Database> get database async {
    if (_isWeb) {
      throw UnsupportedError('SQLite database not supported on web platform');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        birthday TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for faster email lookups
    await db.execute('''
      CREATE INDEX idx_users_email ON $_tableName (email)
    ''');
  }

  /// Handle database upgrades
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle future database schema upgrades
    if (oldVersion < 2) {
      // Add upgrade logic here when needed
    }
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password against hash
  bool _verifyPassword(String password, String hash) {
    final passwordHash = _hashPassword(password);
    return passwordHash == hash;
  }

  /// Generate unique user ID
  String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Register new user
  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
    DateTime? birthday,
  }) async {
    try {
      if (_isWeb) {
        return await _registerUserWeb(
          name: name,
          email: email,
          password: password,
          birthday: birthday,
        );
      } else {
        return await _registerUserMobile(
          name: name,
          email: email,
          password: password,
          birthday: birthday,
        );
      }
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  /// Register user on web platform using SharedPreferences
  Future<User?> _registerUserWeb({
    required String name,
    required String email,
    required String password,
    DateTime? birthday,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    List<Map<String, dynamic>> users = [];
    if (usersData != null) {
      users = List<Map<String, dynamic>>.from(jsonDecode(usersData));
    }

    // Check if email already exists
    final existingUser = users.firstWhere(
      (user) => user['email'] == email.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email already registered');
    }

    final userId = _generateUserId();
    final passwordHash = _hashPassword(password);
    final now = DateTime.now().toIso8601String();

    final userData = {
      'id': userId,
      'name': name,
      'email': email.toLowerCase(),
      'password_hash': passwordHash,
      'birthday': birthday?.toIso8601String(),
      'created_at': now,
      'updated_at': now,
    };

    users.add(userData);
    await prefs.setString(_usersKey, jsonEncode(users));

    return User(
      id: userId,
      name: name,
      email: email.toLowerCase(),
      birthday: birthday,
      createdAt: DateTime.parse(now),
    );
  }

  /// Register user on mobile/desktop using SQLite
  Future<User?> _registerUserMobile({
    required String name,
    required String email,
    required String password,
    DateTime? birthday,
  }) async {
    final db = await database;

    // Check if email already exists
    final existingUser = await getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Email already registered');
    }

    final userId = _generateUserId();
    final passwordHash = _hashPassword(password);
    final now = DateTime.now().toIso8601String();

    final userData = {
      'id': userId,
      'name': name,
      'email': email.toLowerCase(),
      'password_hash': passwordHash,
      'birthday': birthday?.toIso8601String(),
      'created_at': now,
      'updated_at': now,
    };

    await db.insert(_tableName, userData);

    return User(
      id: userId,
      name: name,
      email: email.toLowerCase(),
      birthday: birthday,
      createdAt: DateTime.parse(now),
    );
  }

  /// Authenticate user login
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (_isWeb) {
        return await _loginUserWeb(email: email, password: password);
      } else {
        return await _loginUserMobile(email: email, password: password);
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Login user on web platform
  Future<User?> _loginUserWeb({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData == null) return null;

    final List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(
      jsonDecode(usersData),
    );

    final userData = users.firstWhere(
      (user) => user['email'] == email.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );

    if (userData.isEmpty) return null;

    final storedHash = userData['password_hash'] as String;

    if (_verifyPassword(password, storedHash)) {
      return User(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        birthday:
            userData['birthday'] != null
                ? DateTime.parse(userData['birthday'] as String)
                : null,
        createdAt: DateTime.parse(userData['created_at'] as String),
      );
    }

    return null;
  }

  /// Login user on mobile/desktop platform
  Future<User?> _loginUserMobile({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final userData = maps.first;
    final storedHash = userData['password_hash'] as String;

    if (_verifyPassword(password, storedHash)) {
      return User(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        birthday:
            userData['birthday'] != null
                ? DateTime.parse(userData['birthday'] as String)
                : null,
        createdAt: DateTime.parse(userData['created_at'] as String),
      );
    }

    return null;
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      if (_isWeb) {
        return await _getUserByEmailWeb(email);
      } else {
        return await _getUserByEmailMobile(email);
      }
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  /// Get user by email on web platform
  Future<User?> _getUserByEmailWeb(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData == null) return null;

    final List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(
      jsonDecode(usersData),
    );

    final userData = users.firstWhere(
      (user) => user['email'] == email.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );

    if (userData.isEmpty) return null;

    return User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      birthday:
          userData['birthday'] != null
              ? DateTime.parse(userData['birthday'] as String)
              : null,
      createdAt: DateTime.parse(userData['created_at'] as String),
    );
  }

  /// Get user by email on mobile platform
  Future<User?> _getUserByEmailMobile(String email) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final userData = maps.first;
    return User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      birthday:
          userData['birthday'] != null
              ? DateTime.parse(userData['birthday'] as String)
              : null,
      createdAt: DateTime.parse(userData['created_at'] as String),
    );
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    try {
      if (_isWeb) {
        return await _getUserByIdWeb(id);
      } else {
        return await _getUserByIdMobile(id);
      }
    } catch (e) {
      print('Get user by ID error: $e');
      return null;
    }
  }

  /// Get user by ID on web platform
  Future<User?> _getUserByIdWeb(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData == null) return null;

    final List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(
      jsonDecode(usersData),
    );

    final userData = users.firstWhere(
      (user) => user['id'] == id,
      orElse: () => <String, dynamic>{},
    );

    if (userData.isEmpty) return null;

    return User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      birthday:
          userData['birthday'] != null
              ? DateTime.parse(userData['birthday'] as String)
              : null,
      createdAt: DateTime.parse(userData['created_at'] as String),
    );
  }

  /// Get user by ID on mobile platform
  Future<User?> _getUserByIdMobile(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final userData = maps.first;
    return User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      birthday:
          userData['birthday'] != null
              ? DateTime.parse(userData['birthday'] as String)
              : null,
      createdAt: DateTime.parse(userData['created_at'] as String),
    );
  }

  /// Update user profile
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? email,
    DateTime? birthday,
  }) async {
    try {
      final db = await database;

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (email != null) {
        // Check if new email is already taken by another user
        final existingUser = await getUserByEmail(email);
        if (existingUser != null && existingUser.id != userId) {
          throw Exception('Email already in use');
        }
        updates['email'] = email.toLowerCase();
      }
      if (birthday != null) updates['birthday'] = birthday.toIso8601String();

      final result = await db.update(
        _tableName,
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  /// Change user password
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final db = await database;

      // Verify current password
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isEmpty) return false;

      final userData = maps.first;
      final storedHash = userData['password_hash'] as String;

      if (!_verifyPassword(currentPassword, storedHash)) {
        return false; // Current password is incorrect
      }

      // Update with new password
      final newPasswordHash = _hashPassword(newPassword);
      final result = await db.update(
        _tableName,
        {
          'password_hash': newPasswordHash,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteUser(String userId) async {
    try {
      final db = await database;

      final result = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      print('Delete user error: $e');
      return false;
    }
  }

  /// Get all users (for admin purposes - use with caution)
  Future<List<User>> getAllUsers() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'created_at DESC',
      );

      return maps
          .map(
            (userData) => User(
              id: userData['id'] as String,
              name: userData['name'] as String,
              email: userData['email'] as String,
              birthday:
                  userData['birthday'] != null
                      ? DateTime.parse(userData['birthday'] as String)
                      : null,
              createdAt: DateTime.parse(userData['created_at'] as String),
            ),
          )
          .toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  /// Get users count
  Future<int> getUsersCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Get users count error: $e');
      return 0;
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // Password must be at least 6 characters
    if (password.length < 6) return false;

    // Must contain at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }

  /// Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    if (!hasLetter) return 'Password must contain at least one letter';
    if (!hasNumber) return 'Password must contain at least one number';

    return 'Password is valid';
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete database (for development/testing)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
