import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';

class MindfulnessSessionScreen extends StatelessWidget {
  const MindfulnessSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Mindfulness Sessions'),
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
                    const Text(
                      'Audio Sessions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _SessionCard(
                      title: 'Quick Reset (2 min)',
                      description:
                          'A brief mindfulness session to reset your focus',
                      duration: '2 min',
                      icon: Icons.timer_rounded,
                    ),
                    const _SessionCard(
                      title: 'Stress Relief (5 min)',
                      description:
                          'Deep relaxation to release tension and stress',
                      duration: '5 min',
                      icon: Icons.spa_rounded,
                    ),
                    const _SessionCard(
                      title: 'Focus Boost (3 min)',
                      description: 'Enhance concentration and mental clarity',
                      duration: '3 min',
                      icon: Icons.center_focus_strong_rounded,
                    ),
                    const _SessionCard(
                      title: 'Evening Wind Down (5 min)',
                      description: 'Calm your mind after a long day',
                      duration: '5 min',
                      icon: Icons.nightlight_round,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.music_note_rounded,
                            size: 48,
                            color: Color(0xFF7B68EE),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Relaxation Music',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Healing frequencies and ambient sounds',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Play relaxation music
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Music player coming soon!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B68EE),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Play Music'),
                          ),
                        ],
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

class _SessionCard extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final IconData icon;

  const _SessionCard({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7B68EE).withOpacity(0.2),
          child: Icon(icon, color: const Color(0xFF7B68EE)),
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
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        trailing: Chip(
          label: Text(duration),
          backgroundColor: const Color(0xFF7B68EE).withOpacity(0.2),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
        onTap: () {
          // TODO: Play audio session
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playing: $title')),
          );
        },
      ),
    );
  }
}
