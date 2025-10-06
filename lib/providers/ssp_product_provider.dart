import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/ssp_product_service.dart';

/// Provider for managing SSP (Server-Side Provider) products
class SSPProductProvider with ChangeNotifier {
  final SSPProductService _sspProductService = SSPProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get featuredProducts =>
      _products.where((p) => p.rating >= 4.5).toList();

  List<Product> get bestSellers =>
      _products.where((p) => p.rating >= 4.0).take(6).toList();

  List<Product> get newArrivals => _products.take(4).toList();

  /// Load products from SSP
  Future<void> loadProductsFromSSP() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _sspProductService.fetchProductsFromSSP();
      _error = null;
    } catch (e) {
      _error = 'Failed to load products from SSP: $e';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery) ||
          product.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  /// Refresh products
  Future<void> refreshProducts() async {
    await loadProductsFromSSP();
  }
}
