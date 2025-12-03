import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import 'zen_mode_screen.dart';

class ZenActivityScreen extends StatefulWidget {
  final ZenActivity activity;

  const ZenActivityScreen({super.key, required this.activity});

  @override
  State<ZenActivityScreen> createState() => _ZenActivityScreenState();
}

class _ZenActivityScreenState extends State<ZenActivityScreen>
    with TickerProviderStateMixin {
  bool _isActive = false;
  bool _isCompleted = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startActivity() {
    setState(() {
      _isActive = true;
      _elapsedSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  Future<void> _completeActivity() async {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _isCompleted = true;
    });

    // Award Zen Points
    await _awardZenPoints();

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog();
    }
  }

  Future<void> _awardZenPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt('zen_points') ?? 0;
    final pointsAwarded = _calculatePoints();
    await prefs.setInt('zen_points', currentPoints + pointsAwarded);

    // Update streak
    final lastActivityDate = prefs.getString('last_zen_activity_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastActivityDate != today) {
      final currentStreak = prefs.getInt('zen_streak') ?? 0;
      final newStreak =
          lastActivityDate != null && _isYesterday(lastActivityDate)
              ? currentStreak + 1
              : 1;
      await prefs.setInt('zen_streak', newStreak);
      await prefs.setString('last_zen_activity_date', today);
    }

    // Check for badge unlocks
    await _checkBadgeUnlocks(prefs, currentPoints + pointsAwarded);
  }

  int _calculatePoints() {
    // Base points + time bonus
    return 10 + (_elapsedSeconds ~/ 30);
  }

  bool _isYesterday(String dateStr) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateStr == yesterday.toIso8601String().split('T')[0];
  }

  Future<void> _checkBadgeUnlocks(
      SharedPreferences prefs, int totalPoints) async {
    final badges = prefs.getStringList('zen_badges') ?? [];

    if (totalPoints >= 100 && !badges.contains('silent_warrior')) {
      badges.add('silent_warrior');
      _showBadgeUnlock('Silent Warrior');
    }
    if (widget.activity.category == 'eye_care' &&
        !badges.contains('eye_guardian')) {
      final eyeActivities = prefs.getInt('eye_activities') ?? 0;
      if (eyeActivities >= 10) {
        badges.add('eye_guardian');
        _showBadgeUnlock('Eye Guardian');
      }
      await prefs.setInt('eye_activities', eyeActivities + 1);
    }
    if (widget.activity.category == 'mindfulness' &&
        !badges.contains('breath_master')) {
      final breathActivities = prefs.getInt('breath_activities') ?? 0;
      if (breathActivities >= 20) {
        badges.add('breath_master');
        _showBadgeUnlock('Breath Master');
      }
      await prefs.setInt('breath_activities', breathActivities + 1);
    }

    await prefs.setStringList('zen_badges', badges);
  }

  void _showBadgeUnlock(String badgeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber),
            const SizedBox(width: 12),
            Text('Badge Unlocked: $badgeName! 🎉'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text(
              'Activity Complete!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You earned ${_calculatePoints()} Zen Points!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keep up the great work! Your Growth Score has been updated.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: widget.activity.title),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Activity Icon
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isActive ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getCategoryColor().withOpacity(0.6),
                                  _getCategoryColor().withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Icon(
                              widget.activity.icon,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Activity Description
                    Text(
                      widget.activity.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Activity-specific content
                    _buildActivityContent(),

                    const SizedBox(height: 32),

                    // Timer
                    if (_isActive)
                      Text(
                        _formatTime(_elapsedSeconds),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Action Button
                    if (!_isCompleted)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              _isActive ? _completeActivity : _startActivity,
                          style: FilledButton.styleFrom(
                            backgroundColor: _getCategoryColor(),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _isActive ? 'Complete Activity' : 'Start Activity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildActivityContent() {
    switch (widget.activity.id) {
      case 'breathing_reset':
        return _buildBreathingReset();
      case 'box_breathing':
        return _buildBoxBreathing();
      case 'grounding_54321':
        return _buildGrounding54321();
      case '20_20_20_rule':
        return _build202020Rule();
      case 'gratitude_flash':
        return _buildGratitudeFlash();
      default:
        return _buildGenericGuide();
    }
  }

  Widget _buildBreathingReset() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Breathing Pattern',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreathStep('Inhale', '4 seconds', Icons.arrow_upward),
          _buildBreathStep('Hold', '2 seconds', Icons.pause),
          _buildBreathStep('Exhale', '6 seconds', Icons.arrow_downward),
        ],
      ),
    );
  }

  Widget _buildBreathStep(String label, String duration, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Text(
            '$label: $duration',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxBreathing() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'Box Breathing Pattern',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Inhale 4s → Hold 4s → Exhale 4s → Hold 4s\nRepeat this cycle',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrounding54321() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5-4-3-2-1 Grounding',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildGroundingStep('5', 'Things you can see'),
          _buildGroundingStep('4', 'Things you can touch'),
          _buildGroundingStep('3', 'Things you can hear'),
          _buildGroundingStep('2', 'Things you can smell'),
          _buildGroundingStep('1', 'Thing you can taste'),
        ],
      ),
    );
  }

  Widget _buildGroundingStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getCategoryColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build202020Rule() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '20-20-20 Rule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Every 20 minutes, look at something 20 feet away for 20 seconds',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Look away from your screen now and focus on something in the distance',
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGratitudeFlash() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Gratitude Flash',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Take a moment to think of one person or thing you\'re grateful for today',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 48,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Activity Guide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getActivityInstructions(),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getActivityInstructions() {
    switch (widget.activity.id) {
      case 'mindful_sitting':
        return 'Sit comfortably. Feel your seat beneath you. Keep your spine straight but relaxed. Drop your shoulders. Breathe naturally.';
      case 'thought_cloud':
        return 'Visualize your thoughts as clouds in the sky. Watch them drift by without judgment. Let them pass naturally.';
      case 'blink_relax':
        return 'Close your eyes gently. Blink slowly 10 times. Feel the moisture return to your eyes.';
      case 'palm_massage':
        return 'Rub your palms together until warm. Cup them over your closed eyes. Feel the warmth and darkness.';
      case 'jaw_relaxation':
        return 'Relax your jaw. Let it drop slightly. Massage your temples gently. Release tension.';
      case 'neck_shoulder_drop':
        return 'Roll your shoulders back and down. Tilt your head side to side gently. Release all tension.';
      default:
        return 'Follow the activity instructions. Take your time. Be present in the moment.';
    }
  }

  Color _getCategoryColor() {
    switch (widget.activity.category) {
      case 'mindfulness':
        return const Color(0xFF4A90E2);
      case 'eye_care':
        return const Color(0xFF7B68EE);
      case 'stress_relief':
        return const Color(0xFFE74C3C);
      case 'audio':
        return const Color(0xFF9B59B6);
      case 'cognitive':
        return const Color(0xFFF39C12);
      case 'emotional':
        return const Color(0xFFE91E63);
      case 'work_rhythm':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF4A90E2);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
