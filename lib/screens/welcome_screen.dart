import 'package:flutter/material.dart';
import 'package:breakup_recovery/services/auth_service.dart';
import 'package:breakup_recovery/services/firestore_service.dart';
import 'package:breakup_recovery/screens/main_navigation_screen.dart';
import 'package:breakup_recovery/theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Breakup Recovery',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your journey to healing starts here. Get personalized guidance and support.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    if (!_isLogin) ...[
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  if (!_isLogin) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleEmailSignUp,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_isLogin) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleGuestSignIn,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Continue as Guest'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        if (_isLogin) {
                          _showLoginDialog();
                        } else {
                          setState(() => _isLogin = true);
                        }
                      },
                      child: Text(_isLogin ? 'Sign In with Email' : 'Back'),
                    ),
                  ),
                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = false),
                      child: const Text('Create Account'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInAnonymously();
      final user = _authService.currentUser;
      if (user != null) {
        // Create initial plan
        await _firestoreService.createPlan(user.uid);
        _navigateToMainScreen();
      }
    } catch (e) {
      _showErrorDialog('Failed to continue as guest');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final user = _authService.currentUser;
      if (user != null) {
        await _firestoreService.createPlan(user.uid);
        _navigateToMainScreen();
      }
    } catch (e) {
      _showErrorDialog('Failed to create account');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => LoginDialog(
        onLogin: (email, password) async {
          try {
            await _authService.signInWithEmailAndPassword(email, password);
            _navigateToMainScreen();
          } catch (e) {
            _showErrorDialog('Invalid email or password');
          }
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }
}

class LoginDialog extends StatefulWidget {
  final Function(String, String) onLogin;

  const LoginDialog({super.key, required this.onLogin});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign In'),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    await widget.onLogin(_emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop();
  }
}