import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Service class for managing geolocation functionality
class LocationService with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Position>? _positionStream;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocation => _currentPosition != null;

  /// Get current location
  Future<bool> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error =
            'Location services are disabled. Please enable location services.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error =
              'Location permission denied. Please grant location permission.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error =
            'Location permissions are permanently denied. Please enable them in settings.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to get location: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Start location tracking
  void startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Location tracking error: $error';
        notifyListeners();
      },
    );
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Get formatted location string
  String getLocationString() {
    if (_currentPosition == null) return 'Location not available';

    return 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
        'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}';
  }

  /// Get distance to a specific location
  double? getDistanceTo(double latitude, double longitude) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Get location accuracy info
  String getAccuracyInfo() {
    if (_currentPosition == null) return 'No location data';

    return 'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m, '
        'Speed: ${_currentPosition!.speed.toStringAsFixed(1)}m/s';
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
