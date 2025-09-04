import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:breakup_recovery/services/auth_service.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/screens/main_navigation_screen.dart';
import 'package:breakup_recovery/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AuthService _authService = AuthService();
  final BreakupRecoveryRepository _repository = BreakupRecoveryRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BRSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHero(),
                    const SizedBox(height: BRSpacing.xxl),
                    if (!_showEmailForm) ...[
                      _buildWelcomeButtons(),
                    ] else ...[
                      _buildEmailForm(),
                    ],
                  ],
                ),
              ),
              if (_showEmailForm) _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        // Hero icon with gradient background
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BRColors.primaryGradientStart, BRColors.primaryGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(BRRadius.standard),
            boxShadow: BRShadows.card,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: BRSpacing.lg),
        Text(
          'Breakup Recovery',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: BRColors.text,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BRSpacing.md),
        Text(
          'Your personalized journey to healing and growth. Get expert guidance, track your progress, and rebuild your confidence.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: BRColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWelcomeButtons() {
    return Column(
      children: [
        // Continue as Guest button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: BRShadows.button,
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleContinueAsGuest,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Continue as Guest'),
          ),
        ),
        const SizedBox(height: BRSpacing.md),
        
        // Email Login button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: BRShadows.soft,
          ),
          child: OutlinedButton(
            onPressed: _isLoading ? null : () {
              HapticFeedback.lightImpact();
              setState(() => _showEmailForm = true);
            },
            child: const Text('Sign In with Email'),
          ),
        ),
        
        const SizedBox(height: BRSpacing.xl),
        
        // Terms and Privacy
        Text(
          'By continuing, you agree to our Terms of Service and Privacy Policy',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: BRColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Container(
      padding: const EdgeInsets.all(BRSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BRRadius.standard),
        boxShadow: BRShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLogin ? 'Welcome Back' : 'Create Account',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: BRSpacing.lg),
          
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: BRSpacing.md),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: BRSpacing.lg),
          
          // Submit button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: BRShadows.button,
            ),
            child: ElevatedButton(
              onPressed: _canSubmit ? _handleEmailAuth : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_isLogin ? 'Sign In' : 'Create Account'),
            ),
          ),
          const SizedBox(height: BRSpacing.md),
          
          // Switch between login/register
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : () {
                setState(() => _isLogin = !_isLogin);
                HapticFeedback.selectionClick();
              },
              child: Text(
                _isLogin 
                    ? 'Don\'t have an account? Create one'
                    : 'Already have an account? Sign in',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: _isLoading ? null : () {
        setState(() => _showEmailForm = false);
        HapticFeedback.lightImpact();
      },
      icon: const Icon(Icons.arrow_back_rounded),
      label: const Text('Back to options'),
    );
  }

  bool get _canSubmit => 
      _emailController.text.trim().isNotEmpty && 
      _passwordController.text.trim().isNotEmpty && 
      _emailController.text.contains('@');

  Future<void> _handleContinueAsGuest() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // Sign in anonymously
      await _authService.signInAnonymously();
      
      // Initialize user and create recovery plan
      await _repository.initializeNewUser();
      
      if (mounted) {
        // Navigate to main navigation
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to continue as guest: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEmailAuth() async {
    if (_isLoading || !_canSubmit) return;
    
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        await _authService.signInWithEmailAndPassword(email, password);
      } else {
        await _authService.createUserWithEmailAndPassword(email, password);
      }

      // Initialize user and create recovery plan if needed
      await _repository.initializeNewUser();

      if (mounted) {
        // Navigate to main navigation
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to ${_isLogin ? 'sign in' : 'create account'}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BRColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}