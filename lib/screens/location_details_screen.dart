import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';

/// Detailed location screen with tracking and information
class LocationDetailsScreen extends StatefulWidget {
  const LocationDetailsScreen({super.key});

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Details'),
        elevation: 0,
        actions: [
          Consumer<LocationService>(
            builder: (context, locationService, child) {
              return IconButton(
                icon: Icon(
                  _isTracking ? Icons.location_disabled : Icons.my_location,
                ),
                onPressed: () {
                  if (_isTracking) {
                    locationService.stopLocationTracking();
                    setState(() => _isTracking = false);
                  } else {
                    locationService.startLocationTracking();
                    setState(() => _isTracking = true);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<LocationService>(
        builder: (context, locationService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Location Card
                _buildCurrentLocationCard(locationService),
                const SizedBox(height: 16),

                // Location Visual
                _buildLocationVisual(locationService),
                const SizedBox(height: 16),

                // Location Details
                _buildLocationDetails(locationService),
                const SizedBox(height: 16),

                // Tracking Status
                _buildTrackingStatus(locationService),
                const SizedBox(height: 16),

                // Control Buttons
                _buildControlButtons(locationService),
                const SizedBox(height: 16),

                // Coffee Shop Distances (Mock)
                _buildNearbyShops(locationService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentLocationCard(LocationService locationService) {
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
                      locationService.hasLocation ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Location',
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
                  Text('Getting your location...'),
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
                    onPressed: () {
                      locationService.clearError();
                      locationService.getCurrentLocation();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              )
            else if (locationService.hasLocation)
              Text(locationService.getLocationString())
            else
              const Text('Location not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationVisual(LocationService locationService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Location Indicator',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      locationService.hasLocation ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          locationService.hasLocation
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                      border: Border.all(
                        color:
                            locationService.hasLocation
                                ? Colors.blue
                                : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.my_location,
                      size: 40,
                      color:
                          locationService.hasLocation
                              ? Colors.blue
                              : Colors.grey,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              locationService.hasLocation ? 'Location Found' : 'Searching...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: locationService.hasLocation ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetails(LocationService locationService) {
    if (!locationService.hasLocation) return const SizedBox.shrink();

    final position = locationService.currentPosition!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Location Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Latitude', position.latitude.toStringAsFixed(6)),
            _buildDetailRow('Longitude', position.longitude.toStringAsFixed(6)),
            _buildDetailRow(
              'Accuracy',
              '${position.accuracy.toStringAsFixed(1)} m',
            ),
            _buildDetailRow(
              'Altitude',
              '${position.altitude.toStringAsFixed(1)} m',
            ),
            _buildDetailRow(
              'Speed',
              '${position.speed.toStringAsFixed(1)} m/s',
            ),
            _buildDetailRow(
              'Heading',
              '${position.heading.toStringAsFixed(1)}°',
            ),
            _buildDetailRow('Timestamp', _formatTimestamp(position.timestamp)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStatus(LocationService locationService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                  color: _isTracking ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location Tracking',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isTracking
                  ? 'Continuously tracking your location'
                  : 'Location tracking is disabled',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _isTracking
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _isTracking ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: _isTracking ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(LocationService locationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed:
              locationService.isLoading
                  ? null
                  : () => locationService.getCurrentLocation(),
          icon:
              locationService.isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.my_location),
          label: Text(
            locationService.isLoading
                ? 'Getting Location...'
                : 'Get Current Location',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            if (_isTracking) {
              locationService.stopLocationTracking();
              setState(() => _isTracking = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location tracking stopped')),
              );
            } else {
              locationService.startLocationTracking();
              setState(() => _isTracking = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location tracking started')),
              );
            }
          },
          icon: Icon(
            _isTracking ? Icons.location_disabled : Icons.location_searching,
          ),
          label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyShops(LocationService locationService) {
    if (!locationService.hasLocation) return const SizedBox.shrink();

    // Mock coffee shop locations
    final mockShops = [
      {'name': 'Central Brew', 'lat': 6.9271, 'lng': 79.8612},
      {'name': 'Coffee Corner', 'lat': 6.9344, 'lng': 79.8428},
      {'name': 'Bean There', 'lat': 6.9147, 'lng': 79.8723},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_cafe, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  'Nearby Coffee Shops',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...mockShops.map((shop) {
              final distance = locationService.getDistanceTo(
                shop['lat'] as double,
                shop['lng'] as double,
              );

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_cafe),
                title: Text(shop['name'] as String),
                subtitle: Text(
                  distance != null
                      ? '${(distance / 1000).toStringAsFixed(1)} km away'
                      : 'Distance unknown',
                ),
                trailing: const Icon(Icons.directions),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
