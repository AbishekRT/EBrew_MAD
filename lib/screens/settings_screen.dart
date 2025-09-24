import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

/// Screen 6: Settings & Profile
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  double _fontSizeMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              _buildProfileSection(),
              const SizedBox(height: 24),

              // Theme Settings
              _buildThemeSection(),
              const SizedBox(height: 24),

              // App Preferences
              _buildPreferencesSection(),
              const SizedBox(height: 24),

              // Device Permissions
              _buildPermissionsSection(),
              const SizedBox(height: 24),

              // About Section
              _buildAboutSection(),
              const SizedBox(height: 24),

              // Logout Button
              _buildLogoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?.email ?? 'No email',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Member since ${user?.createdAt.year ?? DateTime.now().year}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showEditProfileDialog();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme Mode'),
                  subtitle: Text(_getThemeModeString(themeProvider.themeMode)),
                  trailing: Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Font Size'),
                  subtitle: Slider(
                    value: _fontSizeMultiplier,
                    min: 0.8,
                    max: 1.4,
                    divisions: 3,
                    label: '${(_fontSizeMultiplier * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _fontSizeMultiplier = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.location_on),
              title: const Text('Location Services'),
              subtitle: const Text('Allow location access'),
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Permissions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              subtitle: const Text('Take photos and videos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/camera-demo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_searching),
              title: const Text('Location'),
              subtitle: const Text('Access device location'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/location-details');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sensors),
              title: const Text('Device Sensors'),
              subtitle: const Text('Accelerometer and gyroscope'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/sensor-demo');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
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
                Text('About', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('App Version'),
              subtitle: const Text('2.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Developer'),
              subtitle: const Text('eBrew Development Team'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.launch),
              onTap: () {
                _showPrivacyDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          color: Colors.red.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () {
                          _showLogoutDialog();
                        },
                icon:
                    authProvider.isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.logout),
                label: Text(
                  authProvider.isLoading ? 'Logging out...' : 'Logout',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Profile'),
            content: const Text('Profile editing functionality would go here.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help'),
            content: const Text(
              'This is the settings screen where you can:\n\n'
              '• Manage your profile\n'
              '• Change app theme\n'
              '• Adjust preferences\n'
              '• View app information\n'
              '• Manage permissions',
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const Text(
              'Your privacy is important to us. This app collects location data and device information only with your permission and for the purposes of providing coffee shop services.',
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
