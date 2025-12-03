import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';

class PulseMomentsScreen extends StatelessWidget {
  const PulseMomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Weekly Pulse Moments'),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD72631), Color(0xFF8B1A1F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'This Week\'s Highlights',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Top performers across all modules',
                                  style: TextStyle(
                                    fontSize: 14,
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

                    // Top Learning Stars (Skill Sparks)
                    _buildMomentCard(
                      context,
                      title: '🌟 Top Learning Stars',
                      subtitle: 'Skill Sparks Champions',
                      icon: Icons.bolt_rounded,
                      color: Colors.amber,
                      moments: [
                        _MomentItem(
                          name: 'Sarah Johnson',
                          achievement: 'Completed 25 micro-learning sessions',
                          value: '25 sessions',
                        ),
                        _MomentItem(
                          name: 'Mike Chen',
                          achievement: 'Mastered 3 new tech skills',
                          value: '3 skills',
                        ),
                        _MomentItem(
                          name: 'Emma Wilson',
                          achievement: '7-day learning streak',
                          value: '7 days',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Top Brain Forge Players
                    _buildMomentCard(
                      context,
                      title: '🧩 Brain Forge Masters',
                      subtitle: 'Cognitive Champions',
                      icon: Icons.psychology_rounded,
                      color: Colors.purple,
                      moments: [
                        _MomentItem(
                          name: 'David Martinez',
                          achievement: 'Solved 50 puzzles this week',
                          value: '50 puzzles',
                        ),
                        _MomentItem(
                          name: 'Alex Kumar',
                          achievement: 'Highest score: 9,850',
                          value: '9,850 pts',
                        ),
                        _MomentItem(
                          name: 'Lisa Park',
                          achievement: 'Perfect streak: 12 games',
                          value: '12 games',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Idea Lab Winners
                    _buildMomentCard(
                      context,
                      title: '💡 Innovation Leaders',
                      subtitle: 'Idea Lab Winners',
                      icon: Icons.lightbulb_rounded,
                      color: Colors.orange,
                      moments: [
                        _MomentItem(
                          name: 'Team Alpha',
                          achievement: 'Best innovation: AI Analytics Tool',
                          value: 'Top Idea',
                        ),
                        _MomentItem(
                          name: 'John Smith',
                          achievement: 'Submitted 5 winning ideas',
                          value: '5 ideas',
                        ),
                        _MomentItem(
                          name: 'Maria Garcia',
                          achievement: 'Highest impact score: 95/100',
                          value: '95 pts',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Mind Balance Streaks
                    _buildMomentCard(
                      context,
                      title: '🧘 Zen Masters',
                      subtitle: 'Mind Balance Champions',
                      icon: Icons.self_improvement_rounded,
                      color: Colors.green,
                      moments: [
                        _MomentItem(
                          name: 'Robert Lee',
                          achievement: '30-day mindfulness streak',
                          value: '30 days',
                        ),
                        _MomentItem(
                          name: 'Sophie Brown',
                          achievement: '500 Zen Points earned',
                          value: '500 pts',
                        ),
                        _MomentItem(
                          name: 'James Taylor',
                          achievement: 'Unlocked all badges',
                          value: 'All badges',
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

  Widget _buildMomentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<_MomentItem> moments,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...moments.asMap().entries.map((entry) {
            final index = entry.key;
            final moment = entry.value;
            return Container(
              margin:
                  EdgeInsets.only(bottom: index < moments.length - 1 ? 16 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moment.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          moment.achievement,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      moment.value,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MomentItem {
  final String name;
  final String achievement;
  final String value;

  _MomentItem({
    required this.name,
    required this.achievement,
    required this.value,
  });
}
