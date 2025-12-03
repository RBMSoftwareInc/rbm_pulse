import 'package:flutter/material.dart';
import '../models/growth_data.dart';

class AvatarModeScreen extends StatefulWidget {
  final GrowthMetrics metrics;
  final GrowthPrediction prediction;

  const AvatarModeScreen({
    super.key,
    required this.metrics,
    required this.prediction,
  });

  @override
  State<AvatarModeScreen> createState() => _AvatarModeScreenState();
}

class _AvatarModeScreenState extends State<AvatarModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final growthRating = widget.metrics.futureGrowthRating;
    final dominantTraits = widget.metrics.dominantTraits;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withOpacity(
                          _glowAnimation.value * (growthRating / 100)),
                      Colors.blue.withOpacity(_glowAnimation.value * 0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.purple.withOpacity(_glowAnimation.value * 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Avatar Icon
                    Icon(
                      Icons.person_rounded,
                      size: 120,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    // Growth Indicator
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${growthRating.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Personality Traits
          const Text(
            'Your Growth Traits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: dominantTraits.map((trait) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: trait.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: trait.color,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trait.icon, color: trait.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      trait.displayName,
                      style: TextStyle(
                        color: trait.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Growth Metrics Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Growth Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _MetricRow('Skill Sparks', widget.metrics.skillSparksScore,
                    Colors.amber),
                _MetricRow(
                    'Brain Forge', widget.metrics.brainForgeScore, Colors.blue),
                _MetricRow('Mind Balance',
                    widget.metrics.mindBalanceStreak / 30 * 100, Colors.green),
                _MetricRow('Focus Zone', widget.metrics.focusZoneDiscipline,
                    Colors.purple),
                _MetricRow('Thought Circles',
                    widget.metrics.thoughtCirclesParticipation, Colors.teal),
                _MetricRow('Idea Lab', widget.metrics.ideaLabImpactScore,
                    Colors.orange),
                _MetricRow('Meeting Room',
                    widget.metrics.meetingRoomContribution, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MetricRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
