import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

const logoAsset = 'assets/logo/rbm-logo.svg';

class CurtainScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const CurtainScreen({super.key, required this.onLogin});

  @override
  State<CurtainScreen> createState() => _CurtainScreenState();
}

class _CurtainScreenState extends State<CurtainScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _logoController;
  late Animation<double> _curtainAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoRotation;
  late Animation<double> _logoScale;
  late Animation<double> _logoGlow;
  bool _curtainRaised = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _curtainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Logo animations
    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.linear,
      ),
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _raiseCurtain() async {
    if (_curtainRaised) return;
    _curtainRaised = true;

    // Check if curtain was already shown
    final prefs = await SharedPreferences.getInstance();
    final curtainShown = prefs.getBool('curtain_shown') ?? false;

    if (curtainShown) {
      // Skip animation if already shown before
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(onLogin: widget.onLogin),
          ),
        );
      }
      return;
    }

    // Mark as shown
    await prefs.setBool('curtain_shown', true);

    // Start animation
    await _controller.forward();

    // Navigate to login after animation
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginScreen(onLogin: widget.onLogin),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: GestureDetector(
        onTap: _raiseCurtain,
        child: Stack(
          children: [
            // Content behind curtain
            _buildContent(),

            // Curtain overlay
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Left curtain
                    Positioned(
                      left: -MediaQuery.of(context).size.width *
                          _curtainAnimation.value,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1A1A1A),
                              Color(0xFF0A0A0A),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _CurtainPainter(
                            side: CurtainSide.left,
                            animation: _curtainAnimation.value,
                          ),
                        ),
                      ),
                    ),

                    // Right curtain
                    Positioned(
                      right: -MediaQuery.of(context).size.width *
                          _curtainAnimation.value,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF1A1A1A),
                              Color(0xFF0A0A0A),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _CurtainPainter(
                            side: CurtainSide.right,
                            animation: _curtainAnimation.value,
                          ),
                        ),
                      ),
                    ),

                    // Fade overlay
                    Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
            ),

            // Tap instruction
            if (!_curtainRaised)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Column(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white70,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap anywhere to begin',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B1B1B),
            Color(0xFF2C2C2C),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Animated Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateY(_logoRotation.value *
                            2 *
                            3.14159) // Y-axis rotation
                        ..rotateX(0.1 *
                            _logoRotation.value *
                            2 *
                            3.14159) // Slight X-axis rotation
                        ..scale(_logoScale.value),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFD72631)
                                  .withOpacity(_logoGlow.value),
                              const Color(0xFFD72631)
                                  .withOpacity(_logoGlow.value * 0.5),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD72631)
                                  .withOpacity(_logoGlow.value * 0.8),
                              blurRadius: 50 * _logoGlow.value,
                              spreadRadius: 20 * _logoGlow.value,
                            ),
                            BoxShadow(
                              color: const Color(0xFFD72631)
                                  .withOpacity(_logoGlow.value * 0.4),
                              blurRadius: 100 * _logoGlow.value,
                              spreadRadius: 30 * _logoGlow.value,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // White circle background
                            Container(
                              width: 160,
                              height: 160,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white24,
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            // 3D Logo with depth
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.002)
                                ..rotateY(
                                    _logoRotation.value * 2 * 3.14159 * 0.5)
                                ..translate(0.0, 0.0,
                                    10.0), // Z translation for 3D effect
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: Offset(
                                        5 * (_logoRotation.value - 0.5),
                                        5 * (_logoRotation.value - 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: SvgPicture.asset(
                                    logoAsset,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFD72631),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Shine effect
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateZ(_logoRotation.value * 2 * 3.14159),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.0),
                                      Colors.white
                                          .withOpacity(0.3 * _logoGlow.value),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                    stops: const [0.0, 0.3, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // App Name
                const Text(
                  'RBM-Pulse',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // Tagline
                Text(
                  'Scientific Wellbeing at Your Fingertips',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Features
                _buildFeature(
                  icon: Icons.assessment_rounded,
                  title: 'Scientific Surveys',
                  description:
                      'Evidence-based questionnaires using validated scales like Gallup Q12, UWES, and PHQ-2',
                ),
                const SizedBox(height: 24),
                _buildFeature(
                  icon: Icons.analytics_rounded,
                  title: 'AI-Powered Analytics',
                  description:
                      'Get insights into team wellbeing, engagement, and burnout risk with intelligent analytics',
                ),
                const SizedBox(height: 24),
                _buildFeature(
                  icon: Icons.school_rounded,
                  title: 'Growth & Learning',
                  description:
                      'Access micro-learning, brain games, ideation forums, and wellness resources',
                ),
                const SizedBox(height: 24),
                _buildFeature(
                  icon: Icons.nfc_rounded,
                  title: 'Quick NFC Login',
                  description:
                      'Tap your ID card for instant, secure access to your wellbeing dashboard',
                ),
                const SizedBox(height: 40),

                // Purpose
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD72631).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD72631).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFD72631),
                        size: 32,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Our Purpose',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'RBM-Pulse helps organizations track employee wellbeing through scientific methods, enabling data-driven decisions to create healthier, more engaged workplaces.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD72631).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFD72631),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum CurtainSide { left, right }

class _CurtainPainter extends CustomPainter {
  final CurtainSide side;
  final double animation;

  _CurtainPainter({required this.side, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1A1A1A);

    // Draw curtain folds
    const foldCount = 8;
    final foldWidth = size.width / foldCount;

    for (int i = 0; i < foldCount; i++) {
      final x = i * foldWidth;
      final foldHeight = size.height;
      final foldOffset = (animation * 20) * (i % 2 == 0 ? 1 : -1);

      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + foldWidth, 0)
        ..lineTo(x + foldWidth + foldOffset, foldHeight)
        ..lineTo(x + foldOffset, foldHeight)
        ..close();

      canvas.drawPath(path, paint);

      // Add shadow for depth
      final shadowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black.withOpacity(0.3);
      canvas.drawPath(path, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(_CurtainPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
