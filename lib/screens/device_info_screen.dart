import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/connectivity_service.dart';

/// Screen 5: Device Information & Location
class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Info'), elevation: 0),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connectivity Status Card
              _buildConnectivityCard(),
              const SizedBox(height: 16),

              // Location Information Card
              _buildLocationCard(),
              const SizedBox(height: 16),

              // Device Specifications Card
              _buildDeviceSpecsCard(),
              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectivityCard() {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      connectivityService.isConnected
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color:
                          connectivityService.isConnected
                              ? Colors.green
                              : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Network Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  connectivityService.getStatusMessage(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        connectivityService.isConnected
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    connectivityService.isConnected ? 'Online' : 'Offline',
                    style: TextStyle(
                      color:
                          connectivityService.isConnected
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.bold,
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

  Widget _buildLocationCard() {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      locationService.hasLocation
                          ? Icons.location_on
                          : Icons.location_off,
                      color:
                          locationService.hasLocation
                              ? Colors.green
                              : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Location Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (locationService.isLoading)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Getting location...'),
                    ],
                  )
                else if (locationService.error != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationService.error!,
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => locationService.getCurrentLocation(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  )
                else if (locationService.hasLocation)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locationService.getLocationString()),
                      const SizedBox(height: 4),
                      Text(
                        locationService.getAccuracyInfo(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => locationService.getCurrentLocation(),
                    icon: const Icon(Icons.my_location),
                    label: const Text('Get Location'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceSpecsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Device Specifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSpecRow(
              'Screen Size',
              '${MediaQuery.of(context).size.width.toInt()} x ${MediaQuery.of(context).size.height.toInt()}',
            ),
            _buildSpecRow(
              'Pixel Ratio',
              MediaQuery.of(context).devicePixelRatio.toStringAsFixed(1),
            ),
            _buildSpecRow(
              'Orientation',
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 'Portrait'
                  : 'Landscape',
            ),
            _buildSpecRow(
              'Platform',
              Theme.of(context).platform.name.toUpperCase(),
            ),
            _buildSpecRow(
              'Brightness',
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? 'Dark'
                  : 'Light',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/location-details');
          },
          icon: const Icon(Icons.location_searching),
          label: const Text('Location Details'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/sensor-demo');
          },
          icon: const Icon(Icons.sensors),
          label: const Text('Sensor Demo'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
