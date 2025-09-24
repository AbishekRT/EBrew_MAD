import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service class for managing network connectivity
class ConnectivityService with ChangeNotifier {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _isConnected = false;

  // Getters
  ConnectivityResult get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;
  String get connectionType => _getConnectionType();

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    final Connectivity connectivity = Connectivity();

    // Check initial connectivity status
    final List<ConnectivityResult> results =
        await connectivity.checkConnectivity();
    _connectionStatus =
        results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(_connectionStatus);

    // Listen to connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _connectionStatus =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(_connectionStatus);
    });
  }

  /// Update connection status and notify listeners
  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();

    if (kDebugMode) {
      print('Connectivity changed: ${_getConnectionType()}');
    }
  }

  /// Get human-readable connection type
  String _getConnectionType() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  /// Get connection status message
  String getStatusMessage() {
    if (_isConnected) {
      return 'Connected via ${_getConnectionType()}';
    } else {
      return 'No internet connection';
    }
  }

  /// Check if specific features are available based on connection
  bool canSync() => _isConnected;
  bool canStreamVideo() => _connectionStatus == ConnectivityResult.wifi;
  bool canDownloadLargeFiles() => _connectionStatus == ConnectivityResult.wifi;

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
