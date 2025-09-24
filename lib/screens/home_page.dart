import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/connectivity_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

            // Best Selling Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Best Selling Products', style: sectionTitleStyle),
            ),

            const SizedBox(height: 12),

            // Featured Products from ProductService
            Consumer<ProductService>(
              builder: (context, productService, child) {
                final featuredProducts = productService.getFeaturedProducts();

                if (featuredProducts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No products available')),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      isLandscape || isWide
                          ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 4 / 3,
                                ),
                            itemCount: featuredProducts.length,
                            itemBuilder:
                                (context, index) => _buildProductCard(
                                  featuredProducts[index],
                                  isDarkMode,
                                ),
                          )
                          : Column(
                            children:
                                featuredProducts
                                    .map(
                                      (product) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildProductCard(
                                          product,
                                          isDarkMode,
                                        ),
                                      ),
                                    )
                                    .toList(),
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
            cartProvider.setSelectedProduct(product);
            Navigator.pushNamed(context, '/product-detail');
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    product.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_cafe, size: 50),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs. ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.orange[200]
                                      : Colors.brown[700],
                            ),
                          ),
                          const Spacer(),
                          if (!product.inStock)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Out of Stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
