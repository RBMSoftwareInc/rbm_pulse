import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTourService {
  static const String _tourCompletedKey = 'app_tour_completed';

  /// Check if tour has been completed
  static Future<bool> isTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tourCompletedKey) ?? false;
  }

  /// Mark tour as completed
  static Future<void> completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourCompletedKey, true);
  }

  /// Reset tour (for testing or re-showing)
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourCompletedKey, false);
  }

  /// Show app tour for first-time users
  static Future<void> showTourIfNeeded(BuildContext context) async {
    final completed = await isTourCompleted();
    if (!completed && context.mounted) {
      await showAppTour(context);
    }
  }

  /// Show the app tour dialog
  static Future<void> showAppTour(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AppTourDialog(),
    );
  }
}

/// App Tour Dialog - Simple step-by-step guide
class AppTourDialog extends StatefulWidget {
  const AppTourDialog({super.key});

  @override
  State<AppTourDialog> createState() => _AppTourDialogState();
}

class _AppTourDialogState extends State<AppTourDialog> {
  int _currentStep = 0;

  final List<AppTourStep> _steps = [
    AppTourStep(
      title: 'Welcome to RBM-Pulse!',
      description:
          'Start your daily check-in here to share your wellbeing and track your mood.',
      icon: Icons.check_circle_outline,
      color: const Color(0xFFD72631),
    ),
    AppTourStep(
      title: 'My History',
      description:
          'View your check-in history and track your wellbeing journey over time.',
      icon: Icons.history,
      color: const Color(0xFF00A86B),
    ),
    AppTourStep(
      title: 'Achievements & Streaks',
      description:
          'Earn achievements and build streaks by maintaining consistent check-ins.',
      icon: Icons.star,
      color: const Color(0xFFFFA500),
    ),
    AppTourStep(
      title: 'Learning Hub',
      description:
          'Access wellness tips, micro-learning, ideation forums, and gamification to grow and connect.',
      icon: Icons.school_rounded,
      color: const Color(0xFF6A0DAD),
    ),
    AppTourStep(
      title: 'Menu Navigation',
      description:
          'Open the hamburger menu to access all features including the Learning Hub and App Tour.',
      icon: Icons.menu,
      color: const Color(0xFF0F52BA),
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeTour();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTour() {
    _completeTour();
  }

  void _completeTour() {
    AppTourService.completeTour();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: step.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: step.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _steps.length,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(step.color),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentStep + 1}/${_steps.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.icon,
                      size: 48,
                      color: step.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  TextButton(
                    onPressed: _skipTour,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: step.color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTourStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  AppTourStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
