import 'package:flutter/material.dart';

class WellnessTipsScreen extends StatelessWidget {
  const WellnessTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Wisdom'),
        backgroundColor: const Color(0xFF6A0DAD),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _TipCard(
              title: 'Mindful Breathing',
              description:
                  'Take 5 deep breaths when feeling stressed. Inhale for 4 counts, hold for 4, exhale for 4.',
              icon: Icons.air,
              color: Color(0xFF6A0DAD),
            ),
            _TipCard(
              title: 'Micro Breaks',
              description:
                  'Take a 2-minute break every hour. Stand up, stretch, or look outside.',
              icon: Icons.timer,
              color: Color(0xFF9D4EDD),
            ),
            _TipCard(
              title: 'Gratitude Practice',
              description:
                  'Write down 3 things you\'re grateful for each day. It boosts positivity.',
              icon: Icons.favorite,
              color: Color(0xFF6A0DAD),
            ),
            _TipCard(
              title: 'Hydration Reminder',
              description:
                  'Keep a water bottle nearby. Aim for 8 glasses of water daily.',
              icon: Icons.water_drop,
              color: Color(0xFF9D4EDD),
            ),
            _TipCard(
              title: 'Digital Detox',
              description:
                  'Take 30 minutes before bed without screens. Read or meditate instead.',
              icon: Icons.phone_android,
              color: Color(0xFF6A0DAD),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _TipCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
