import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import 'screens/focus_timer_screen.dart';
import 'screens/learning_content_screen.dart';

class FocusZoneScreen extends StatelessWidget {
  const FocusZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Focus Zone'),
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
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A0DAD), Color(0xFF9D4EDD)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Focus Zone',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Anti-doom-scrolling mode',
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

                    // Focus Timer
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6A0DAD).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Focus Session',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF6A0DAD),
                                width: 4,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '25:00',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FocusTimerScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A0DAD),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Start Focus Session'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Insight Reels
                    const Text(
                      'Insight Reels',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _InsightCard(
                      title: 'Mindful Breathing',
                      content: 'Take 5 deep breaths to reset your focus',
                      type: 'Wellness',
                    ),
                    const _InsightCard(
                      title: 'Productivity Tip',
                      content:
                          'The Pomodoro Technique: 25 min work, 5 min break',
                      type: 'Productivity',
                    ),
                    const _InsightCard(
                      title: 'Tech Insight',
                      content:
                          'Did you know? Regular breaks improve code quality',
                      type: 'Tech',
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

class _InsightCard extends StatelessWidget {
  final String title;
  final String content;
  final String type;

  const _InsightCard({
    required this.title,
    required this.content,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6A0DAD).withOpacity(0.2),
          child: const Icon(
            Icons.visibility_rounded,
            color: Color(0xFF6A0DAD),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          content,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        trailing: Chip(
          label: Text(type),
          backgroundColor: const Color(0xFF6A0DAD).withOpacity(0.2),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearningContentScreen(
                title: title,
                category: type,
                type: 'Insight',
                content: _getInsightContent(title, content),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getInsightContent(String title, String content) {
    switch (title) {
      case 'Mindful Breathing':
        return 'Mindful breathing is a powerful technique to reset your focus:\n\n'
            '1. Find a comfortable position\n'
            '2. Inhale slowly through your nose for 4 counts\n'
            '3. Hold your breath for 4 counts\n'
            '4. Exhale slowly through your mouth for 4 counts\n'
            '5. Repeat 5 times\n\n'
            'This activates your parasympathetic nervous system, reducing stress and improving focus.';
      case 'Productivity Tip':
        return 'The Pomodoro Technique is a time management method:\n\n'
            '• Work for 25 minutes (one Pomodoro)\n'
            '• Take a 5-minute break\n'
            '• After 4 Pomodoros, take a longer 15-30 minute break\n\n'
            'Benefits:\n'
            '• Prevents burnout\n'
            '• Maintains focus\n'
            '• Improves time awareness\n'
            '• Increases productivity';
      case 'Tech Insight':
        return 'Research shows that regular breaks significantly improve code quality:\n\n'
            '• Developers who take breaks every 90 minutes produce 20% better code\n'
            '• Short breaks reduce cognitive fatigue\n'
            '• Physical movement during breaks boosts creativity\n'
            '• Social breaks improve team collaboration\n\n'
            'Remember: Taking breaks is not slacking off—it\'s optimizing your performance.';
      default:
        return content;
    }
  }
}
