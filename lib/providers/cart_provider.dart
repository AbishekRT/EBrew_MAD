import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/cart_database_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final CartDatabaseService _dbService = CartDatabaseService();
  Product? _selectedProduct;
  bool _isLoading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  Product? get selectedProduct => _selectedProduct;
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;

  Future<void> initializeCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cartItems = await _dbService.getAllCartItems();
      _items.clear();
      _items.addAll(cartItems);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart from database: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        _items[existingIndex].quantity += quantity;
        await _dbService.addOrUpdateCartItem(_items[existingIndex]);
      } else {
        final cartItem = CartItem(product: product, quantity: quantity);
        _items.add(cartItem);
        await _dbService.addOrUpdateCartItem(cartItem);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item to cart: $e');
      }
    }
  }

  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<bool> checkout() async {
    if (_items.isEmpty) return false;

    await Future.delayed(const Duration(seconds: 2));
    await clearCart();
    return true;
  }

  Future<void> removeFromCart(String productId) async {
    try {
      _items.removeWhere((item) => item.product.id == productId);
      await _dbService.removeCartItem(productId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing item from cart: $e');
      }
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    try {
      final index = _items.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        _items[index].quantity = quantity;
        await _dbService.updateCartItemQuantity(productId, quantity);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating quantity: $e');
      }
    }
  }

  Future<void> increaseQuantity(String productId) async {
    try {
      final index = _items.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        _items[index].quantity++;
        await _dbService.updateCartItemQuantity(
          productId,
          _items[index].quantity,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error increasing quantity: $e');
      }
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    try {
      final index = _items.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        if (_items[index].quantity > 1) {
          _items[index].quantity--;
          await _dbService.updateCartItemQuantity(
            productId,
            _items[index].quantity,
          );
        } else {
          _items.removeAt(index);
          await _dbService.removeCartItem(productId);
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error decreasing quantity: $e');
      }
    }
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse:
          () => CartItem(
            product: Product(
              id: '',
              name: '',
              price: 0,
              image: '',
              category: '',
              description: '',
              tastingNotes: '',
              roastLevel: '',
              origin: '',
              rating: 0,
              inStock: false,
            ),
            quantity: 0,
          ),
    );
    return item.quantity;
  }

  Future<void> clearCart() async {
    try {
      _items.clear();
      await _dbService.clearCart();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cart: $e');
      }
    }
  }
}
