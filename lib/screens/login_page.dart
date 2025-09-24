import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration('Email', Icons.email),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email cannot be empty';
        } else if (!value.contains('@')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: _inputDecoration('Password', Icons.lock),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password cannot be empty';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final headingStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? const Color(0xFFFFF3E0) : const Color(0xFF3E2723),
    );

    final subtextStyle = TextStyle(
      fontSize: 16,
      color: isDarkMode ? const Color(0xFFFFCCBC) : const Color(0xFF5D4037),
    );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor:
          isDarkMode ? const Color(0xFF6D4C41) : const Color(0xFFA1887F),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      textStyle: const TextStyle(fontSize: 16),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('eBrew Login'),
        centerTitle: true,
        backgroundColor:
            isDarkMode ? const Color(0xFF4E342E) : const Color(0xFFD7CCC8),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 600 ? screenWidth : 500,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to eBrew!', style: headingStyle),
                  const SizedBox(height: 10),
                  Text('Please login to continue', style: subtextStyle),
                  const SizedBox(height: 30),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return ElevatedButton.icon(
                          onPressed: authProvider.isLoading ? null : _login,
                          icon:
                              authProvider.isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.login),
                          label: Text(
                            authProvider.isLoading ? 'Logging in...' : 'Login',
                          ),
                          style: buttonStyle,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
