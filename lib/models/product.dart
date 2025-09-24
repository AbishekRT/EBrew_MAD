/// Product model class representing a coffee product
class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final String tastingNotes;
  final String roastLevel;
  final String origin;
  final double rating;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.tastingNotes,
    required this.roastLevel,
    required this.origin,
    required this.rating,
    required this.inStock,
  });

  /// Creates a Product from JSON data
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      tastingNotes: json['tastingNotes'] as String,
      roastLevel: json['roastLevel'] as String,
      origin: json['origin'] as String,
      rating: (json['rating'] as num).toDouble(),
      inStock: json['inStock'] as bool,
    );
  }

  /// Converts Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'tastingNotes': tastingNotes,
      'roastLevel': roastLevel,
      'origin': origin,
      'rating': rating,
      'inStock': inStock,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
