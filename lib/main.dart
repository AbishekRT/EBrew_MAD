import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/product_provider.dart';
import 'providers/ssp_product_provider.dart';

// Services
import 'services/product_service.dart';
import 'services/connectivity_service.dart';
import 'services/location_service.dart';
import 'services/sensor_service.dart';

// Screens
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/product.dart';
import 'screens/cart.dart';
import 'screens/faq.dart';
import 'screens/product_detail_page.dart';
import 'screens/device_info_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sensor_demo_screen.dart';
import 'screens/camera_demo_screen.dart';
import 'screens/location_details_screen.dart';
import 'screens/checkout_page.dart';
import 'screens/ssp_demo_products_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // State Management Providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SSPProductProvider()),

        // Service Providers
        Provider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SensorService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'eBrew - Coffee Shop App',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,

            // Initial Route
            home: const AppWrapper(),

            // Route Configuration
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
              '/products': (context) => const ProductPage(),
              '/cart': (context) => CartScreen(),
              '/faq': (context) => const FAQPage(),
              '/product-detail': (context) => const ProductDetail(),
              '/device-info': (context) => const DeviceInfoScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/sensor-demo': (context) => const SensorDemoScreen(),
              '/camera-demo': (context) => const CameraDemoScreen(),
              '/location-details': (context) => const LocationDetailsScreen(),
              '/checkout': (context) => const CheckoutPage(),
              '/ssp-demo-products': (context) => const SSPDemoProductsPage(),
            },
          );
        },
      ),
    );
  }
}

/// Wrapper widget to handle app initialization and routing
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize services
      final productService = Provider.of<ProductService>(
        context,
        listen: false,
      );
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final connectivityService = Provider.of<ConnectivityService>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load products data
      await productService.loadProducts();
      await productProvider.loadProducts();

      // Initialize connectivity monitoring
      await connectivityService.initialize();

      // Initialize authentication state
      await authProvider.initAuth();

      // Initialize cart from SQLite database
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.initializeCart();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('App initialization error: $e');
      setState(() {
        _isInitialized = true; // Continue even if some services fail
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing eBrew...'),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Navigate based on authentication status
        if (authProvider.isLoggedIn) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
