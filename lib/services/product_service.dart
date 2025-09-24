import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

/// Service class for managing product data from local JSON
class ProductService {
  static const String _productsPath = 'assets/data/products.json';

  List<Product> _products = [];
  List<String> _categories = [];

  // Getters
  List<Product> get products => _products;
  List<String> get categories => _categories;

  /// Load products from local JSON file
  Future<List<Product>> loadProducts() async {
    try {
      final String jsonString = await rootBundle.loadString(_productsPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Load products
      final List<dynamic> productsJson = jsonData['products'] as List;
      _products = productsJson.map((json) => Product.fromJson(json)).toList();

      // Load categories
      final List<dynamic> categoriesJson = jsonData['categories'] as List;
      _categories = categoriesJson.map((cat) => cat['name'] as String).toList();

      return _products;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search products by name or description
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery) ||
          product.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get featured products (high rating)
  List<Product> getFeaturedProducts({int limit = 4}) {
    final featured =
        _products.where((product) => product.rating >= 4.5).toList();
    featured.sort((a, b) => b.rating.compareTo(a.rating));
    return featured.take(limit).toList();
  }

  /// Get products on sale (mock implementation)
  List<Product> getOnSaleProducts({int limit = 4}) {
    // For demo purposes, return products with specific IDs as "on sale"
    final saleIds = ['1', '3', '5', '7'];
    return _products
        .where((product) => saleIds.contains(product.id))
        .take(limit)
        .toList();
  }

  /// Get available products (in stock)
  List<Product> getAvailableProducts() {
    return _products.where((product) => product.inStock).toList();
  }
}
