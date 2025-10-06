import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Service class for fetching products from SSP (Server-Side Provider)
class SSPProductService {
  static const String _baseUrl = 'http://16.171.119.252';

  /// Fetch products from SSP
  Future<List<Product>> fetchProductsFromSSP() async {
    try {
      print('SSP: Fetching products from $_baseUrl/api/products');
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('SSP: Received response with status 200');
        final dynamic responseData = json.decode(response.body);
        print('SSP: Raw response data: ${responseData.toString()}');

        // Handle different possible response structures
        List<dynamic> productsJson;
        if (responseData is List) {
          productsJson = responseData;
        } else if (responseData is Map<String, dynamic>) {
          final jsonData = responseData;
          // Check for the actual SSP API structure first
          if (jsonData.containsKey('status') &&
              jsonData['status'] == 'success' &&
              jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              productsJson = data;
            } else if (data is Map) {
              productsJson = [data];
            } else {
              throw Exception('Invalid data structure in SSP response');
            }
          } else if (jsonData.containsKey('products')) {
            productsJson = jsonData['products'] as List;
          } else if (jsonData.containsKey('data')) {
            productsJson = jsonData['data'] as List;
          } else {
            throw Exception(
              'Unexpected response structure - expected array or object with products/data key. Response: ${jsonData.toString()}',
            );
          }
        } else {
          throw Exception('Unexpected response type');
        }

        print('SSP: Found ${productsJson.length} products in response');
        final mappedProducts =
            productsJson.map((json) => _mapSSPProductToLocal(json)).toList();
        print('SSP: Successfully mapped ${mappedProducts.length} products');
        print(
          'SSP: First product name: ${mappedProducts.isNotEmpty ? mappedProducts[0].name : "None"}',
        );
        return mappedProducts;
      } else {
        throw Exception(
          'Failed to fetch products: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching products from SSP: $e');
    }
  }

  /// Map SSP product structure to local Product model
  Product _mapSSPProductToLocal(Map<String, dynamic> sspProduct) {
    return Product(
      id:
          sspProduct['id']?.toString() ??
          sspProduct['Id']?.toString() ??
          sspProduct['productId']?.toString() ??
          '',
      name:
          sspProduct['Name']?.toString() ??
          sspProduct['name']?.toString() ??
          sspProduct['title']?.toString() ??
          'Unknown Product',
      price: _parsePrice(
        sspProduct['Price'] ?? sspProduct['price'] ?? sspProduct['cost'] ?? 0,
      ),
      image:
          sspProduct['Image']?.toString() ??
          sspProduct['image']?.toString() ??
          sspProduct['imageUrl']?.toString() ??
          'assets/1.png',
      category:
          sspProduct['Category']?.toString() ??
          sspProduct['category']?.toString() ??
          'Coffee',
      description:
          sspProduct['Description']?.toString() ??
          sspProduct['description']?.toString() ??
          'No description available',
      tastingNotes:
          sspProduct['TastingNotes']?.toString() ??
          sspProduct['tastingNotes']?.toString() ??
          sspProduct['notes']?.toString() ??
          'No tasting notes',
      roastLevel:
          sspProduct['RoastLevel']?.toString() ??
          sspProduct['roastLevel']?.toString() ??
          sspProduct['roast']?.toString() ??
          'Medium',
      origin:
          sspProduct['Origin']?.toString() ??
          sspProduct['origin']?.toString() ??
          sspProduct['country']?.toString() ??
          'Unknown',
      rating: _parseRating(
        sspProduct['Rating'] ??
            sspProduct['rating'] ??
            sspProduct['score'] ??
            4.0,
      ),
      inStock:
          sspProduct['InStock'] ??
          sspProduct['inStock'] ??
          sspProduct['available'] ??
          true,
    );
  }

  double _parsePrice(dynamic price) {
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  double _parseRating(dynamic rating) {
    if (rating is num) return rating.toDouble().clamp(0.0, 5.0);
    if (rating is String)
      return (double.tryParse(rating) ?? 4.0).clamp(0.0, 5.0);
    return 4.0;
  }

  /// Fetch single product by ID from SSP
  Future<Product?> fetchProductByIdFromSSP(String productId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/products/$productId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          return _mapSSPProductToLocal(responseData);
        } else {
          throw Exception('Unexpected single product response format');
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product from SSP: $e');
    }
  }
}
