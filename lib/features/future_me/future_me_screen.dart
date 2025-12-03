import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/widgets/shimmer_card.dart';
import '../../core/animations/fade_in_animation.dart';
import '../../core/utils/navigation_helper.dart';
import 'models/growth_data.dart';
import 'services/growth_service.dart';
import 'screens/avatar_mode_screen.dart';
import 'screens/skill_tree_mode_screen.dart';
import 'screens/growth_prediction_screen.dart';
import 'screens/weekly_challenges_screen.dart';

class FutureMeScreen extends StatefulWidget {
  const FutureMeScreen({super.key});

  @override
  State<FutureMeScreen> createState() => _FutureMeScreenState();
}

class _FutureMeScreenState extends State<FutureMeScreen> {
  final GrowthService _service = GrowthService();
  GrowthMetrics? _metrics;
  GrowthPrediction? _prediction;
  bool _isLoading = true;
  bool _viewMode = false; // false = Avatar, true = Skill Tree

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final userId = session?.user.id;
      if (userId == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      final metrics = await _service.getGrowthMetrics(userId);
      final prediction = await _service.getGrowthPrediction(userId, metrics);
      if (mounted) {
        setState(() {
          _metrics = metrics;
          _prediction = prediction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user info for notifications
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id;

    return Scaffold(
      appBar: AppHeader(
        title: 'Future Me',
        showBackButton: false,
        userId: userId,
      ),
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
              child: _isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: 4,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ShimmerCard(height: index == 0 ? 200 : 150),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A0DAD), Color(0xFF9D4EDD)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Future Me',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Growth Rating: ${_metrics!.futureGrowthRating.toStringAsFixed(1)}/100',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // View Mode Switcher
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ModeButton(
                                    label: 'Avatar',
                                    icon: Icons.person_rounded,
                                    isSelected: !_viewMode,
                                    onTap: () =>
                                        setState(() => _viewMode = false),
                                  ),
                                ),
                                Expanded(
                                  child: _ModeButton(
                                    label: 'Skill Tree',
                                    icon: Icons.account_tree_rounded,
                                    isSelected: _viewMode,
                                    onTap: () =>
                                        setState(() => _viewMode = true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Main View (Avatar or Skill Tree)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _viewMode
                                ? SkillTreeModeScreen(
                                    key: const ValueKey('skill_tree'),
                                    metrics: _metrics!,
                                  )
                                : AvatarModeScreen(
                                    key: const ValueKey('avatar'),
                                    metrics: _metrics!,
                                    prediction: _prediction!,
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickActionCard(
                                  title: 'Growth Prediction',
                                  icon: Icons.trending_up_rounded,
                                  color: Colors.green,
                                  onTap: () {
                                    NavigationHelper.pushSlide(
                                      context,
                                      GrowthPredictionScreen(
                                        metrics: _metrics!,
                                        prediction: _prediction!,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionCard(
                                  title: 'Weekly Challenges',
                                  icon: Icons.emoji_events_rounded,
                                  color: Colors.amber,
                                  onTap: () {
                                    NavigationHelper.pushSlide(
                                      context,
                                      const WeeklyChallengesScreen(),
                                    );
                                  },
                                ),
                              ),
                            ],
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

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A0DAD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
