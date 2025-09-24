import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Service class for managing device sensors (accelerometer, gyroscope)
class SensorService with ChangeNotifier {
  // Accelerometer data
  AccelerometerEvent? _accelerometerEvent;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Gyroscope data
  GyroscopeEvent? _gyroscopeEvent;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // User accelerometer data (without gravity)
  UserAccelerometerEvent? _userAccelerometerEvent;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;

  // Status tracking
  bool _isListening = false;
  String? _error;

  // Getters
  AccelerometerEvent? get accelerometerEvent => _accelerometerEvent;
  GyroscopeEvent? get gyroscopeEvent => _gyroscopeEvent;
  UserAccelerometerEvent? get userAccelerometerEvent => _userAccelerometerEvent;
  bool get isListening => _isListening;
  String? get error => _error;

  /// Start listening to all sensors
  void startListening() {
    if (_isListening) return;

    _error = null;
    _isListening = true;

    try {
      // Start accelerometer
      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerEvent = event;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Accelerometer error: $error';
          notifyListeners();
        },
      );

      // Start gyroscope
      _gyroscopeSubscription = gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _gyroscopeEvent = event;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Gyroscope error: $error';
          notifyListeners();
        },
      );

      // Start user accelerometer
      _userAccelerometerSubscription = userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          _userAccelerometerEvent = event;
          notifyListeners();
        },
        onError: (error) {
          _error = 'User accelerometer error: $error';
          notifyListeners();
        },
      );

      notifyListeners();
    } catch (e) {
      _error = 'Failed to start sensors: $e';
      _isListening = false;
      notifyListeners();
    }
  }

  /// Stop listening to all sensors
  void stopListening() {
    if (!_isListening) return;

    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _userAccelerometerSubscription = null;

    _isListening = false;
    notifyListeners();
  }

  /// Get accelerometer magnitude (overall movement)
  double getAccelerometerMagnitude() {
    if (_accelerometerEvent == null) return 0.0;

    final x = _accelerometerEvent!.x;
    final y = _accelerometerEvent!.y;
    final z = _accelerometerEvent!.z;

    return (x * x + y * y + z * z);
  }

  /// Get gyroscope magnitude (overall rotation)
  double getGyroscopeMagnitude() {
    if (_gyroscopeEvent == null) return 0.0;

    final x = _gyroscopeEvent!.x;
    final y = _gyroscopeEvent!.y;
    final z = _gyroscopeEvent!.z;

    return (x * x + y * y + z * z);
  }

  /// Detect if device is being shaken
  bool isShaking({double threshold = 12.0}) {
    if (_userAccelerometerEvent == null) return false;

    final magnitude = getUserAccelerometerMagnitude();
    return magnitude > threshold;
  }

  /// Get user accelerometer magnitude (without gravity)
  double getUserAccelerometerMagnitude() {
    if (_userAccelerometerEvent == null) return 0.0;

    final x = _userAccelerometerEvent!.x;
    final y = _userAccelerometerEvent!.y;
    final z = _userAccelerometerEvent!.z;

    return (x * x + y * y + z * z);
  }

  /// Get device orientation based on accelerometer
  String getDeviceOrientation() {
    if (_accelerometerEvent == null) return 'Unknown';

    final x = _accelerometerEvent!.x;
    final y = _accelerometerEvent!.y;
    final z = _accelerometerEvent!.z;

    if (z.abs() > x.abs() && z.abs() > y.abs()) {
      return z > 0 ? 'Face Down' : 'Face Up';
    } else if (x.abs() > y.abs()) {
      return x > 0 ? 'Left Side' : 'Right Side';
    } else {
      return y > 0 ? 'Top Down' : 'Bottom Up';
    }
  }

  /// Get formatted sensor data string
  String getSensorDataString() {
    if (_accelerometerEvent == null && _gyroscopeEvent == null) {
      return 'No sensor data available';
    }

    String data = '';

    if (_accelerometerEvent != null) {
      data += 'Accelerometer:\n';
      data += 'X: ${_accelerometerEvent!.x.toStringAsFixed(2)}\n';
      data += 'Y: ${_accelerometerEvent!.y.toStringAsFixed(2)}\n';
      data += 'Z: ${_accelerometerEvent!.z.toStringAsFixed(2)}\n\n';
    }

    if (_gyroscopeEvent != null) {
      data += 'Gyroscope:\n';
      data += 'X: ${_gyroscopeEvent!.x.toStringAsFixed(2)}\n';
      data += 'Y: ${_gyroscopeEvent!.y.toStringAsFixed(2)}\n';
      data += 'Z: ${_gyroscopeEvent!.z.toStringAsFixed(2)}';
    }

    return data;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
