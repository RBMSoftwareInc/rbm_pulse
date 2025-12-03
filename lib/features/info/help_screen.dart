import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Help & Support'),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: const SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HelpSection(
                      title: 'Getting Started',
                      items: [
                        'Complete your daily Pulse Survey to track your wellbeing',
                        'Explore the Learning Hub for growth modules',
                        'Use Mind Balance for emotional wellness',
                        'Check your Growth Score to track progress',
                      ],
                    ),
                    _HelpSection(
                      title: 'Pulse Survey',
                      items: [
                        'Answer questions honestly for accurate insights',
                        'Select your mood color on the color wheel',
                        'Adjust energy and stress levels using sliders',
                        'Add optional notes for additional context',
                      ],
                    ),
                    _HelpSection(
                      title: 'Learning Hub',
                      items: [
                        'Skill Sparks: Quick micro-learning sessions',
                        'Brain Forge: IQ games and puzzles',
                        'Thought Circles: AI-powered discussions',
                        'Idea Lab: Submit innovation ideas',
                        'Focus Zone: Anti-doom-scrolling mode',
                        'Mind Balance: Breathing, mindfulness, gratitude',
                      ],
                    ),
                    _HelpSection(
                      title: 'Troubleshooting',
                      items: [
                        'If login fails, check your credentials',
                        'NFC login requires a registered badge',
                        'Contact IT support for technical issues',
                        'Check app updates for bug fixes',
                      ],
                    ),
                    _HelpSection(
                      title: 'Privacy & Security',
                      items: [
                        'Your responses are anonymous and secure',
                        'Data is encrypted and stored safely',
                        'Only aggregated analytics are visible to HR',
                        'You can request data deletion anytime',
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

class _HelpSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HelpSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
