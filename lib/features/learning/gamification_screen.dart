import 'package:flutter/material.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse Play - Gamification'),
        backgroundColor: const Color(0xFFD72631),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Leaderboard
              Card(
                color: Colors.white.withOpacity(0.05),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      _LeaderboardItem(
                        rank: 1,
                        name: 'Alex Chen',
                        points: 2500,
                        badge: Icons.emoji_events,
                        color: Colors.amber,
                      ),
                      _LeaderboardItem(
                        rank: 2,
                        name: 'Sarah Johnson',
                        points: 2300,
                        badge: Icons.star,
                        color: Colors.grey,
                      ),
                      _LeaderboardItem(
                        rank: 3,
                        name: 'Mike Davis',
                        points: 2100,
                        badge: Icons.star_border,
                        color: Colors.brown,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Your Stats
              Card(
                color: Colors.white.withOpacity(0.05),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBox(
                            label: 'Points',
                            value: '1,250',
                            icon: Icons.stars,
                          ),
                          _StatBox(
                            label: 'Streak',
                            value: '7 days',
                            icon: Icons.local_fire_department,
                          ),
                          _StatBox(
                            label: 'Level',
                            value: '5',
                            icon: Icons.trending_up,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Achievements
              Card(
                color: Colors.white.withOpacity(0.05),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _AchievementBadge(
                            icon: Icons.check_circle,
                            label: 'First Check-in',
                            earned: true,
                          ),
                          _AchievementBadge(
                            icon: Icons.local_fire_department,
                            label: '7 Day Streak',
                            earned: true,
                          ),
                          _AchievementBadge(
                            icon: Icons.forum,
                            label: 'Active Participant',
                            earned: true,
                          ),
                          _AchievementBadge(
                            icon: Icons.school,
                            label: 'Learning Master',
                            earned: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final IconData badge;
  final Color color;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.badge,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Icon(badge, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            '$points pts',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD72631), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool earned;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned
            ? const Color(0xFFD72631).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              earned ? const Color(0xFFD72631) : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: earned ? const Color(0xFFD72631) : Colors.white54,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: earned ? Colors.white : Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
