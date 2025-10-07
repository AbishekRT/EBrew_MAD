import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../providers/ssp_product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    // Load SSP products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SSPProductProvider>().loadProductsFromSSP();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const Text("eBrew Café")],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      body: Consumer<SSPProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading products',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.loadProductsFromSSP(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;

                  return ListView(
                    children: [
                      // Hero Banner
                      Stack(
                        children: [
                          Image.asset(
                            'assets/B1.png',
                            width: double.infinity,
                            height: isWideScreen ? 300 : 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: isWideScreen ? 300 : 200,
                                color: Theme.of(context).primaryColor,
                                child: const Center(
                                  child: Icon(
                                    Icons.local_cafe,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned.fill(
                            child: Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.4),
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'eBrew Café',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Handpicked brews, delivered with care',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // All Products Section
                      _buildProductSection(
                        context,
                        "All Products (${productProvider.products.length})",
                        orientation,
                        productProvider.products,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductSection(
    BuildContext context,
    String title,
    Orientation orientation,
    List<Product> products,
  ) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 24, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children:
                products
                    .map((product) => _buildProductCard(product, context))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(
          '🚀 Navigation - Tapping product: ${product.name} with ID: ${product.id}',
        );
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: product.id.toString(),
        );
      },
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(child: _buildProductImage(product)),
              const SizedBox(height: 8),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Rs. ${product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<CartProvider>().addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build appropriate image widget based on image path
  Widget _buildProductImage(Product product) {
    print(
      '🖼️ Building image for Product ID: ${product.id}, Name: ${product.name}',
    );
    print('🔗 Image URL: ${product.image}');
    if (product.image.startsWith('http')) {
      // Use a unique key and force no caching to ensure unique images
      return Container(
        key: Key(
          'product_img_${product.id}_${DateTime.now().microsecondsSinceEpoch}',
        ),
        width: double.infinity,
        height: 200,
        child: Image.network(
          product.image,
          fit: BoxFit.cover,
          cacheWidth: null, // Disable caching
          cacheHeight: null,
          errorBuilder: (context, error, stackTrace) {
            print('Failed to load network image: ${product.image}');
            return _buildAssetImageFallback(product);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
      );
    }
    return _buildAssetImageFallback(product);
  }

  /// Build asset image fallback
  Widget _buildAssetImageFallback(Product product) {
    return Image.asset(
      'assets/${product.image}',
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey[600],
          ),
        );
      },
    );
  }
}
