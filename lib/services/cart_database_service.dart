import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// SQLite database service for cart data persistence
class CartDatabaseService {
  static Database? _database;
  static const String _tableName = 'cart_items';
  static const String _dbName = 'ebrew_cart.db';
  static const int _dbVersion = 1;

  // Singleton instance
  static final CartDatabaseService _instance = CartDatabaseService._internal();
  factory CartDatabaseService() => _instance;
  CartDatabaseService._internal();

  /// Get database instance
  Future<Database> get database async {
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL UNIQUE,
        product_data TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
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

  /// Add or update cart item
  Future<void> addOrUpdateCartItem(CartItem cartItem) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final data = {
      'product_id': cartItem.product.id,
      'product_data': jsonEncode(cartItem.product.toJson()),
      'quantity': cartItem.quantity,
      'created_at': now,
      'updated_at': now,
    };

    await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all cart items
  Future<List<CartItem>> getAllCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'created_at ASC',
    );

    return maps.map((map) {
      final productData =
          jsonDecode(map['product_data'] as String) as Map<String, dynamic>;
      final product = Product.fromJson(productData);

      return CartItem(product: product, quantity: map['quantity'] as int);
    }).toList();
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    final db = await database;

    if (quantity <= 0) {
      await removeCartItem(productId);
      return;
    }

    await db.update(
      _tableName,
      {'quantity': quantity, 'updated_at': DateTime.now().toIso8601String()},
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  /// Remove cart item
  Future<void> removeCartItem(String productId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Get cart item by product ID
  Future<CartItem?> getCartItem(String productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final productData =
        jsonDecode(map['product_data'] as String) as Map<String, dynamic>;
    final product = Product.fromJson(productData);

    return CartItem(product: product, quantity: map['quantity'] as int);
  }

  /// Get cart items count
  Future<int> getCartItemsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total cart quantity
  Future<int> getTotalCartQuantity() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM $_tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if product is in cart
  Future<bool> isProductInCart(String productId) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    return result.isNotEmpty;
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
