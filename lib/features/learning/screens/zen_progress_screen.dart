import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';

class ZenProgressScreen extends StatefulWidget {
  const ZenProgressScreen({super.key});

  @override
  State<ZenProgressScreen> createState() => _ZenProgressScreenState();
}

class _ZenProgressScreenState extends State<ZenProgressScreen> {
  int _zenPoints = 0;
  int _zenStreak = 0;
  List<String> _badges = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _zenPoints = prefs.getInt('zen_points') ?? 0;
      _zenStreak = prefs.getInt('zen_streak') ?? 0;
      _badges = prefs.getStringList('zen_badges') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Zen Progress'),
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
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Zen Points',
                            value: _zenPoints.toString(),
                            icon: Icons.stars_rounded,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Current Streak',
                            value: '$_zenStreak days',
                            icon: Icons.local_fire_department_rounded,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Badges Section
                    const Text(
                      'Your Badges',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_badges.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 48,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Complete activities to unlock badges!',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: _badges
                            .map((badge) => _BadgeCard(
                                  badgeName: badge,
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 24),

                    // Available Badges
                    const Text(
                      'Available Badges',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BadgeCard(
                      badgeName: 'silent_warrior',
                      isLocked: !_badges.contains('silent_warrior'),
                    ),
                    _BadgeCard(
                      badgeName: 'eye_guardian',
                      isLocked: !_badges.contains('eye_guardian'),
                    ),
                    _BadgeCard(
                      badgeName: 'breath_master',
                      isLocked: !_badges.contains('breath_master'),
                    ),
                    _BadgeCard(
                      badgeName: 'screen_samurai',
                      isLocked: !_badges.contains('screen_samurai'),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String badgeName;
  final bool isLocked;

  const _BadgeCard({
    required this.badgeName,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeInfo = _getBadgeInfo(badgeName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked
            ? Colors.white.withOpacity(0.05)
            : badgeInfo['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? Colors.white.withOpacity(0.1)
              : badgeInfo['color'].withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLocked ? Icons.lock_rounded : badgeInfo['icon'],
            size: 40,
            color: isLocked ? Colors.white54 : badgeInfo['color'],
          ),
          const SizedBox(height: 8),
          Text(
            badgeInfo['name'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.white54 : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (isLocked) ...[
            const SizedBox(height: 4),
            Text(
              badgeInfo['requirement'],
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getBadgeInfo(String badgeName) {
    switch (badgeName) {
      case 'silent_warrior':
        return {
          'name': 'Silent Warrior',
          'icon': Icons.self_improvement_rounded,
          'color': Colors.green,
          'requirement': 'Earn 100 Zen Points',
        };
      case 'eye_guardian':
        return {
          'name': 'Eye Guardian',
          'icon': Icons.remove_red_eye_rounded,
          'color': Colors.blue,
          'requirement': 'Complete 10 eye care activities',
        };
      case 'breath_master':
        return {
          'name': 'Breath Master',
          'icon': Icons.air_rounded,
          'color': Colors.purple,
          'requirement': 'Complete 20 breathing exercises',
        };
      case 'screen_samurai':
        return {
          'name': 'Screen Samurai',
          'icon': Icons.computer_rounded,
          'color': Colors.orange,
          'requirement': 'Complete 30 screen break activities',
        };
      default:
        return {
          'name': 'Badge',
          'icon': Icons.emoji_events_rounded,
          'color': Colors.grey,
          'requirement': '',
        };
    }
  }
}
