import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

/// Cart provider managing shopping cart state
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  Product? _selectedProduct;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  Product? get selectedProduct => _selectedProduct;
  bool get isEmpty => _items.isEmpty;

  /// Add product to cart
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Update existing item quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item to cart
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    notifyListeners();
  }

  /// Remove product from cart completely
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Update quantity of specific item
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  /// Increase item quantity by 1
  void increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decrease item quantity by 1
  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Clear all items from cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Get quantity of specific product in cart
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: '', name: '', price: 0, image: '', category: '', 
        description: '', tastingNotes: '', roastLevel: '', 
        origin: '', rating: 0, inStock: false
      ), quantity: 0),
    );
    return item.quantity;
  }

  /// Set selected product for detail view
  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Simulate checkout process
  Future<bool> checkout() async {
    if (_items.isEmpty) return false;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Clear cart after successful checkout
    clearCart();
    return true;
  }
}