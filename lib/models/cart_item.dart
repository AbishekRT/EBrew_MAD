import 'product.dart';

/// Cart item model representing a product with quantity in the cart
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Calculate total price for this cart item
  double get totalPrice => product.price * quantity;

  /// Creates a CartItem from JSON data
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] as int,
    );
  }

  /// Converts CartItem to JSON
  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
}
