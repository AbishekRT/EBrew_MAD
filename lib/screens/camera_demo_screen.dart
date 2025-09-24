import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// Camera demo screen with preview and basic controls
class CameraDemoScreen extends StatefulWidget {
  const CameraDemoScreen({super.key});

  @override
  State<CameraDemoScreen> createState() => _CameraDemoScreenState();
}

class _CameraDemoScreenState extends State<CameraDemoScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  String? _error;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Request camera permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        setState(() {
          _error =
              'Camera permission denied. Please grant camera access in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No cameras found on this device.';
          _isLoading = false;
        });
        return;
      }

      // Initialize camera controller
      await _initializeCameraController();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeCameraController() async {
    if (_cameras.isEmpty) return;

    _controller?.dispose();
    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isLoading = true;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    await _initializeCameraController();
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      final XFile picture = await _controller!.takePicture();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Picture saved: ${picture.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Demo'),
        elevation: 0,
        actions: [
          if (_cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: _isLoading ? null : _switchCamera,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          _isCameraInitialized
              ? FloatingActionButton(
                onPressed: _takePicture,
                child: const Icon(Icons.camera_alt),
              )
              : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (!_isCameraInitialized || _controller == null) {
      return const Center(child: Text('Camera not available'));
    }

    return Column(
      children: [
        // Camera Preview
        Expanded(
          child: Container(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: CameraPreview(_controller!),
            ),
          ),
        ),

        // Camera Info and Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCameraInfo(),
              const SizedBox(height: 16),
              _buildControlButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraInfo() {
    if (_controller == null) return const SizedBox.shrink();

    final camera = _cameras[_selectedCameraIndex];
    final isRearCamera = camera.lensDirection == CameraLensDirection.back;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.camera,
                  'Camera',
                  isRearCamera ? 'Rear' : 'Front',
                ),
                _buildInfoItem(Icons.high_quality, 'Resolution', 'Medium'),
                _buildInfoItem(
                  Icons.rotate_90_degrees_ccw,
                  'Orientation',
                  '${camera.sensorOrientation}°',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(value, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_cameras.length > 1)
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _switchCamera,
            icon: const Icon(Icons.flip_camera_ios),
            label: const Text('Switch'),
          ),
        ElevatedButton.icon(
          onPressed: _isCameraInitialized ? _takePicture : null,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _showCameraHelp();
          },
          icon: const Icon(Icons.help_outline),
          label: const Text('Help'),
        ),
      ],
    );
  }

  void _showCameraHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Camera Help'),
            content: const Text(
              'Camera Demo Features:\n\n'
              '• Live camera preview\n'
              '• Switch between cameras\n'
              '• Capture photos\n'
              '• Permission handling\n'
              '• Error recovery\n\n'
              'Use the capture button or floating action button to take photos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
