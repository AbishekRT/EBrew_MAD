import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get featuredProducts =>
      _products.where((p) => p.rating >= 4.5).toList();
  List<Product> get bestSellers =>
      _products
          .where((p) => p.id.contains('espresso') || p.id.contains('latte'))
          .toList();
  List<Product> get newArrivals => _products.take(4).toList();

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.loadProducts();
      _error = null;
    } catch (e) {
      _error = 'Failed to load products: $e';
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(category.toLowerCase()),
        )
        .toList();
  }
}
