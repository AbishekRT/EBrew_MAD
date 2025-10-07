import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../providers/ssp_product_provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/connectivity_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load SSP products when home page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sspProvider = Provider.of<SSPProductProvider>(context, listen: false);
      if (sspProvider.products.isEmpty) {
        sspProvider.loadProductsFromSSP();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final headlineStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? const Color(0xFFFFF3E0) : const Color(0xFF3E2723),
    );

    final sectionTitleStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: isDarkMode ? const Color(0xFFFFCCBC) : const Color(0xFF4E342E),
    );

    final bodyTextStyle = TextStyle(
      fontSize: 16,
      height: 1.5,
      color: isDarkMode ? const Color(0xFFFFCCBC) : const Color(0xFF5D4037),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('eBrew'),
        centerTitle: true,
        backgroundColor:
            isDarkMode ? const Color(0xFF4E342E) : const Color(0xFFD7CCC8),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Banner
            Stack(
              children: [
                Image.asset(
                  'assets/B2.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Hero image loading error: $error');
                    return Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
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
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.black.withAlpha(102),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to eBrew Café',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your favorite brews & gadgets in one place.',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Welcome Text Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start Your Day Right ☕', style: headlineStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Discover handcrafted coffee from the best beans. Find your favorites and fuel your mornings with love.',
                    style: bodyTextStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Connectivity Status Banner
            Consumer<ConnectivityService>(
              builder: (context, connectivityService, child) {
                if (!connectivityService.isConnected) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are currently offline. Some features may be limited.',
                            style: TextStyle(color: Colors.orange[800]),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // New Arrivals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('New Arrivals', style: sectionTitleStyle),
            ),

            const SizedBox(height: 12),
            
            // New Arrivals Products (show latest 4 products)
            Consumer<SSPProductProvider>(
              builder: (context, sspProvider, child) {
                if (sspProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (sspProvider.error != null) {
                  return Center(child: Text('Error loading new arrivals'));
                }
                final newArrivals = sspProvider.products.take(4).toList();
                return Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: newArrivals.length,
                    itemBuilder: (context, index) {
                      final product = newArrivals[index];
                      return Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          elevation: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: _buildProductImage(product),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Rs. ${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 11, color: Colors.red[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Best Selling Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Best Selling Products', style: sectionTitleStyle),
            ),

            const SizedBox(height: 12),

            // Featured Products from SSP
            Consumer<SSPProductProvider>(
              builder: (context, sspProductProvider, child) {
                // Handle loading state
                if (sspProductProvider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Handle error state
                if (sspProductProvider.error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Error: ${sspProductProvider.error}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => sspProductProvider.loadProductsFromSSP(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Get middle products (skip first 4 for best sellers)
                final allProducts = sspProductProvider.products;
                final featuredProducts = allProducts.skip(4).take(5).toList();

                if (featuredProducts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No products available')),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLandscape || isWide ? 3 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio:
                          0.75, // Portrait aspect ratio for images
                    ),
                    itemCount: featuredProducts.length,
                    itemBuilder:
                        (context, index) => _buildProductCard(
                          featuredProducts[index],
                          isDarkMode,
                        ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Access Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Access', style: sectionTitleStyle),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/device-info');
                          },
                          icon: const Icon(Icons.phone_android),
                          label: const Text('Device Info'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Settings'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildProductCard(Product product, bool isDarkMode) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product-detail',
              arguments: product.id,
            );
          },
          child: Card(
            color:
                isDarkMode ? const Color(0xFF3E2723) : const Color(0xFFFFF3E0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3, // Give more space to image
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: _buildProductImage(product),
                  ),
                ),
                Expanded(
                  flex: 2, // Give less space to text content
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rs. ${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Rating and stock not available from SSP
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build appropriate image widget for products (same logic as product page)
  /// Build appropriate image widget for products (same logic as product page)
  Widget _buildProductImage(Product product) {
    print('🏠 Home: Building image for ID: ${product.id}, Name: ${product.name}');
    print('🏠 Home: Image URL: ${product.image}');
    if (product.image.startsWith('http')) {
      // Use a unique key and force no caching to ensure unique images
      return Container(
        key: Key('home_img_${product.id}_${DateTime.now().microsecondsSinceEpoch}'),
        width: double.infinity,
        height: 150,
        child: Image.network(
          product.image,
          fit: BoxFit.cover,
          cacheWidth: null, // Disable caching
          cacheHeight: null,
          errorBuilder: (context, error, stackTrace) {
            print('Home: Failed to load network image: ${product.image}');
            return _buildAssetImageFallback(product);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
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
      height: 150,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 150,
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
