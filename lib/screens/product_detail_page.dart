import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetail();
}

class _ProductDetail extends State<ProductDetail> {
  int quantity = 1;
  Product? product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get product ID from route arguments
    final String? productId =
        ModalRoute.of(context)?.settings.arguments as String?;
    if (productId != null) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Load products if not already loaded
      if (productProvider.products.isEmpty && !productProvider.isLoading) {
        productProvider.loadProducts().then((_) {
          if (mounted) {
            setState(() {
              product = productProvider.getProductById(productId);
            });
          }
        });
      } else {
        product = productProvider.getProductById(productId);
      }
    }
  }

  void _changeQuantity(int delta) {
    setState(() {
      quantity = (quantity + delta).clamp(1, 99);
    });
  }

  void _addToCart() {
    if (product != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Add to cart with specified quantity
      for (int i = 0; i < quantity; i++) {
        cartProvider.addToCart(product!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product!.name} (×$quantity) added to cart'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    }
  }

  void _buyNow() {
    if (product != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Add to cart first
      for (int i = 0; i < quantity; i++) {
        cartProvider.addToCart(product!);
      }

      // Navigate to checkout
      Navigator.pushNamed(context, '/checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Show loading while products are being fetched
        if (productProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text("Product Details")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Show error if there was an error loading products
        if (productProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Product Details")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text('Error loading products'),
                  const SizedBox(height: 8),
                  Text(productProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.loadProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Try to get product if we don't have it yet
        if (product == null) {
          final String? productId =
              ModalRoute.of(context)?.settings.arguments as String?;
          if (productId != null) {
            product = productProvider.getProductById(productId);
          }
        }

        // Show not found if product still null
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Product Details")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Product not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildProductDetails();
      },
    );
  }

  Widget _buildProductDetails() {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: Text(product!.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isWideScreen
                ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildImage()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildDetails()),
                  ],
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(),
                      const SizedBox(height: 16),
                      _buildDetails(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildImage() {
    return Center(
      child: Hero(
        tag: 'product-${product!.id}',
        child: Image.asset(
          product!.image,
          width: 250,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 250,
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.local_cafe, size: 64),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product!.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Rs. ${product!.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  product!.rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: product!.inStock ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product!.inStock ? 'In Stock' : 'Out of Stock',
            style: TextStyle(
              color: product!.inStock ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          product!.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _buildInfo("Tasting Notes", product!.tastingNotes),
        _buildInfo("Roast Level", product!.roastLevel),
        _buildInfo("Origin", product!.origin),
        _buildInfo("Category", product!.category),
        const SizedBox(height: 24),
        _buildQuantityAndButtons(),
      ],
    );
  }

  Widget _buildInfo(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuantityAndButtons() {
    return Column(
      children: [
        // Quantity Selector
        Row(
          children: [
            const Text(
              'Quantity:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed:
                        product!.inStock ? () => _changeQuantity(-1) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed:
                        product!.inStock ? () => _changeQuantity(1) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            // Add to Cart Button
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: product!.inStock ? _addToCart : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Buy Now Button
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: product!.inStock ? _buyNow : null,
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),

        if (!product!.inStock)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'This product is currently out of stock',
              style: TextStyle(
                color: Colors.red[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
