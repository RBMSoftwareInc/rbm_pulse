import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  int _breathCount = 0;
  bool _isActive = false;
  String _phase = 'Ready';
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // 4s inhale + 4s exhale
    );
    _breathAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathController.reverse();
        setState(() {
          _phase = _phase == 'Breathe In' ? 'Breathe Out' : 'Breathe In';
        });
      } else if (status == AnimationStatus.dismissed) {
        _breathController.forward();
        setState(() {
          _phase = 'Breathe In';
          _breathCount++;
        });
      }
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _phase = 'Breathe In';
      _breathCount = 0;
    });
    _breathController.forward();
  }

  void _stopBreathing() {
    _breathController.stop();
    _phaseTimer?.cancel();
    setState(() {
      _isActive = false;
      _phase = 'Ready';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Breathing Exercise'),
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _breathAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 200 * _breathAnimation.value,
                          height: 200 * _breathAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF4A90E2).withOpacity(0.6),
                                const Color(0xFF7B68EE).withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _phase,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Breath Count: $_breathCount',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isActive)
                          ElevatedButton.icon(
                            onPressed: _startBreathing,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _stopBreathing,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Follow the circle: Inhale as it expands, exhale as it contracts. Take your time and breathe naturally.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
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
}
