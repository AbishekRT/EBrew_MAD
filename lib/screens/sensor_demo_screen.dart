import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sensor_service.dart';

/// Sensor demonstration screen showing accelerometer and gyroscope data
class SensorDemoScreen extends StatefulWidget {
  const SensorDemoScreen({super.key});

  @override
  State<SensorDemoScreen> createState() => _SensorDemoScreenState();
}

class _SensorDemoScreenState extends State<SensorDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _shakeController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _shakeAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Start sensor listening when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SensorService>(context, listen: false).startListening();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shakeController.dispose();
    // Stop sensor listening when screen is disposed
    Provider.of<SensorService>(context, listen: false).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Demo'),
        elevation: 0,
        actions: [
          Consumer<SensorService>(
            builder: (context, sensorService, child) {
              return IconButton(
                icon: Icon(
                  sensorService.isListening
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                onPressed: () {
                  if (sensorService.isListening) {
                    sensorService.stopListening();
                  } else {
                    sensorService.startListening();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<SensorService>(
        builder: (context, sensorService, child) {
          // Trigger shake animation when device is shaking
          if (sensorService.isShaking()) {
            _shakeController.forward().then((_) => _shakeController.reverse());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                _buildStatusCard(sensorService),
                const SizedBox(height: 16),

                // Visual Feedback
                _buildVisualFeedback(sensorService),
                const SizedBox(height: 16),

                // Accelerometer Data
                _buildAccelerometerCard(sensorService),
                const SizedBox(height: 16),

                // Gyroscope Data
                _buildGyroscopeCard(sensorService),
                const SizedBox(height: 16),

                // Device Orientation
                _buildOrientationCard(sensorService),
                const SizedBox(height: 16),

                // Control Buttons
                _buildControlButtons(sensorService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(SensorService sensorService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  sensorService.isListening ? Icons.sensors : Icons.sensors_off,
                  color: sensorService.isListening ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sensor Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              sensorService.isListening
                  ? 'Sensors are actively monitoring device movement'
                  : 'Sensors are stopped',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (sensorService.error != null) ...[
              const SizedBox(height: 8),
              Text(
                sensorService.error!,
                style: TextStyle(color: Colors.red[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisualFeedback(SensorService sensorService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Visual Feedback',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Rotating coffee cup based on gyroscope
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                final gyroMagnitude = sensorService.getGyroscopeMagnitude();
                final rotationSpeed =
                    gyroMagnitude > 1 ? gyroMagnitude * 0.1 : 0.5;

                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159 * rotationSpeed,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_cafe,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Shake indicator
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          sensorService.isShaking()
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sensorService.isShaking() ? '📳 Shaking!' : '📱 Steady',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            sensorService.isShaking()
                                ? Colors.orange
                                : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccelerometerCard(SensorService sensorService) {
    final event = sensorService.accelerometerEvent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Accelerometer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (event != null) ...[
              _buildSensorValueRow('X-axis', event.x, Colors.red),
              _buildSensorValueRow('Y-axis', event.y, Colors.green),
              _buildSensorValueRow('Z-axis', event.z, Colors.blue),
              const SizedBox(height: 8),
              Text(
                'Magnitude: ${sensorService.getAccelerometerMagnitude().toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else
              const Text('No accelerometer data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildGyroscopeCard(SensorService sensorService) {
    final event = sensorService.gyroscopeEvent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rotate_right, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Gyroscope',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (event != null) ...[
              _buildSensorValueRow('X-axis', event.x, Colors.red),
              _buildSensorValueRow('Y-axis', event.y, Colors.green),
              _buildSensorValueRow('Z-axis', event.z, Colors.blue),
              const SizedBox(height: 8),
              Text(
                'Magnitude: ${sensorService.getGyroscopeMagnitude().toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else
              const Text('No gyroscope data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrientationCard(SensorService sensorService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.screen_rotation, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Device Orientation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sensorService.getDeviceOrientation(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorValueRow(String axis, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 40,
            child: Text(
              axis,
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: (value.abs() / 20).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(SensorService sensorService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed:
              sensorService.isListening
                  ? () => sensorService.stopListening()
                  : () => sensorService.startListening(),
          icon: Icon(sensorService.isListening ? Icons.stop : Icons.play_arrow),
          label: Text(
            sensorService.isListening ? 'Stop Sensors' : 'Start Sensors',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            sensorService.clearError();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sensor data reset'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Data'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
