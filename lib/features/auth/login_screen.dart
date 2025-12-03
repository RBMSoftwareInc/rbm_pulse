import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'register_screen.dart';
import '../../core/animations/fade_in_animation.dart';
import '../../core/animations/scale_animation.dart';

const logoAsset = 'assets/logo/rbm-logo.svg';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;
  bool _biometricAvailable = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  late AnimationController _logoController;
  late Animation<double> _logoRotation;
  late Animation<double> _logoScale;
  late Animation<double> _logoGlow;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _logoRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.linear),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    _logoGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.3, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.3), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final available = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() {
          _biometricAvailable = available && isDeviceSupported;
        });
      }
    } catch (e) {
      // Biometric not available
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _loginWithCredentials() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final email = await _resolveEmail(_identifierController.text.trim());
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Save credentials for biometric login
      if (_biometricAvailable) {
        await _saveBiometricCredentials(email, _passwordController.text.trim());
      }

      // Wait a bit for auth state to update
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        widget.onLogin();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<String> _resolveEmail(String identifier) async {
    if (identifier.contains('@')) return identifier;
    final result = await Supabase.instance.client
        .from('profiles')
        .select('email')
        .eq('username', identifier)
        .maybeSingle();
    final email = result?['email'] as String?;
    if (email == null) {
      throw Exception('No account found for that username.');
    }
    return email;
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
      // Wait a bit for auth state to update
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        widget.onLogin();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Google login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    if (!_biometricAvailable) {
      setState(() {
        _errorMessage =
            'Biometric authentication is not available on this device.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Check if user has saved credentials
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('biometric_email');
      final savedPassword = prefs.getString('biometric_password');

      if (savedEmail == null || savedPassword == null) {
        // First time - need to authenticate with password first
        if (mounted) {
          setState(() {
            _errorMessage =
                'Please login with password first to enable biometric login.';
            _loading = false;
          });
        }
        return;
      }

      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access RBM-Pulse',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Biometric authentication failed.';
            _loading = false;
          });
        }
        return;
      }

      // Login with saved credentials
      await Supabase.instance.client.auth.signInWithPassword(
        email: savedEmail,
        password: savedPassword,
      );

      // Wait a bit for auth state to update
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        widget.onLogin();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Biometric login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveBiometricCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('biometric_email', email);
    await prefs.setString('biometric_password', password);
  }

  Future<void> _openRegistration() async {
    final registered = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (registered == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please login.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor:
          isLight ? const Color(0xFFFAFAFA) : const Color(0xFF1B1B1B),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final isMobile = constraints.maxWidth < 600;

            final content = isWide
                ? Row(
                    children: [
                      Expanded(child: _buildHighlightsPanel()),
                      Expanded(child: _buildFormPanel(isWide)),
                    ],
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      children: [
                        _buildHighlightsPanel(isMobile),
                        SizedBox(height: isMobile ? 16 : 24),
                        _buildFormPanel(isWide, isMobile: isMobile),
                      ],
                    ),
                  );
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: content,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHighlightsPanel([bool isMobile = false]) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD72631),
            Color(0xFF571845),
            Color(0xFF2C1B3D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(isMobile ? 20 : 30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // 3D Animated Logo with fade-in
          ScaleAnimation(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            beginScale: 0.5,
            endScale: 1.0,
            curve: Curves.easeOutBack,
            child: _AnimatedRbmLogo(
              rotation: _logoRotation,
              scale: _logoScale,
              glow: _logoGlow,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          // Title with slide-in
          SlideInAnimation(
            delay: const Duration(milliseconds: 400),
            offset: const Offset(0, -0.3),
            child: Text(
              'RBM-Pulse',
              style: TextStyle(
                fontSize: isMobile ? 32 : 40,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 2,
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // Subtitle with fade-in
          FadeInAnimation(
            delay: const Duration(milliseconds: 600),
            child: Text(
              'Scientific Wellbeing at Your Fingertips',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 0.5,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!isMobile) ...[
            const Spacer(),
            const FadeInAnimation(
              delay: Duration(milliseconds: 800),
              child: Text(
                'Choose your preferred login method on the right.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormPanel(bool isWide, {bool isMobile = false}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF2C2C2C) : Colors.white;
    final fillColor = isLight ? Colors.white : const Color(0xFF2C2C2C);
    final borderColor =
        isLight ? const Color(0xFFE0E0E0) : Colors.white.withOpacity(0.2);

    return SlideInAnimation(
      delay: const Duration(milliseconds: 300),
      offset: const Offset(0.3, 0),
      duration: const Duration(milliseconds: 600),
      child: Center(
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : (isMobile ? 0 : 16),
            vertical: isMobile ? 0 : 24,
          ),
          elevation: 0,
          color: isLight ? Colors.white : const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 20 : 16),
            side: BorderSide(
              color: isLight
                  ? const Color(0xFFE0E0E0)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Email/Username field with animation
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: TextFormField(
                      controller: _identifierController,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email or Username',
                        labelStyle: TextStyle(
                          color: isLight
                              ? const Color(0xFF6C6C6C)
                              : Colors.white70,
                          fontFamily: 'Roboto',
                        ),
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD72631),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isLight
                              ? const Color(0xFF6C6C6C)
                              : Colors.white70,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email or username';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 12),
                  // Password field with animation
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 700),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: isLight
                              ? const Color(0xFF6C6C6C)
                              : Colors.white70,
                          fontFamily: 'Roboto',
                        ),
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD72631),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: isLight
                              ? const Color(0xFF6C6C6C)
                              : Colors.white70,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: isLight
                                ? const Color(0xFF6C6C6C)
                                : Colors.white70,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 20),
                  // Sign in button with animation
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 800),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: FilledButton(
                        onPressed: _loading ? null : _loginWithCredentials,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD72631),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 16 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _loading ? 0 : 4,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto',
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 20),
                  // Divider with animation
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 900),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: borderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF6C6C6C)
                                  : Colors.white70,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: borderColor)),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 16),
                  // Social login buttons with staggered animation
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 1000),
                    child: Wrap(
                      spacing: isMobile ? 8 : 12,
                      runSpacing: isMobile ? 8 : 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _AnimatedSocialButton(
                          delay: const Duration(milliseconds: 1100),
                          icon: Icons.g_mobiledata,
                          label: isMobile ? 'Google' : 'Sign in with Google',
                          onPressed: _loading ? null : _loginWithGoogle,
                          isMobile: isMobile,
                        ),
                        if (_biometricAvailable)
                          _AnimatedSocialButton(
                            delay: const Duration(milliseconds: 1200),
                            icon: Icons.fingerprint,
                            label: isMobile ? 'Biometric' : 'Biometric Login',
                            onPressed: _loading ? null : _loginWithBiometrics,
                            isMobile: isMobile,
                          ),
                      ],
                    ),
                  ),
                  // Error message with animation
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    FadeInAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Register link with animation
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 1300),
                    child: TextButton(
                      onPressed: _loading ? null : _openRegistration,
                      child: Text(
                        "Need an account? Register",
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFFD72631)
                              : Colors.white70,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
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

/// Animated social login button
class _AnimatedSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isMobile;
  final Duration delay;

  const _AnimatedSocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isMobile,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleAnimation(
      delay: delay,
      beginScale: 0.9,
      endScale: 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _AnimatedRbmLogo extends StatelessWidget {
  final Animation<double> rotation;
  final Animation<double> scale;
  final Animation<double> glow;

  const _AnimatedRbmLogo({
    required this.rotation,
    required this.scale,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotation,
      builder: (context, child) {
        final currentScale = scale.value;
        final currentGlow = glow.value;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateX(rotation.value * 0.1) // Subtle X rotation
            ..rotateY(rotation.value), // Y-axis rotation
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(currentGlow),
                  Colors.white.withOpacity(0.8),
                ],
                stops: const [0.0, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD72631).withOpacity(currentGlow * 0.5),
                  blurRadius: 30 * currentGlow,
                  spreadRadius: 5 * currentGlow,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Transform.scale(
              scale: currentScale,
              child: SvgPicture.asset(
                logoAsset,
                height: 70,
                width: 70,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFD72631),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
