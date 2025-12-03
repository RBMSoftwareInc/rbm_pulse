import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';

class MoodCheckScreen extends StatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  State<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends State<MoodCheckScreen> {
  String? _selectedMood;
  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Happy', 'value': 'happy'},
    {'emoji': '😌', 'label': 'Calm', 'value': 'calm'},
    {'emoji': '😰', 'label': 'Anxious', 'value': 'anxious'},
    {'emoji': '😔', 'label': 'Sad', 'value': 'sad'},
    {'emoji': '😴', 'label': 'Tired', 'value': 'tired'},
    {'emoji': '😤', 'label': 'Frustrated', 'value': 'frustrated'},
    {'emoji': '🤔', 'label': 'Thoughtful', 'value': 'thoughtful'},
    {'emoji': '😎', 'label': 'Confident', 'value': 'confident'},
  ];
  String? _recommendation;

  void _checkMood() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your current mood')),
      );
      return;
    }

    // AI-powered recommendations based on mood
    final recommendations = {
      'happy':
          'Great! Keep the positive energy flowing. Consider sharing your joy with others or tackling a creative project.',
      'calm':
          'Wonderful state of mind. This is perfect for focused work or deep thinking tasks.',
      'anxious':
          'Take a moment to breathe. Try a 2-minute breathing exercise or a quick mindfulness session to center yourself.',
      'sad':
          'It\'s okay to feel this way. Consider journaling your thoughts or listening to calming music.',
      'tired':
          'Your body needs rest. Take a short break, do some light stretching, or consider a power nap if possible.',
      'frustrated':
          'Frustration is valid. Step away for a moment, do a breathing exercise, or try a quick walk to reset.',
      'thoughtful':
          'Deep thinking mode. Perfect for problem-solving or planning. Consider journaling your thoughts.',
      'confident':
          'Excellent! Channel this energy into challenging tasks or helping others.',
    };

    setState(() {
      _recommendation = recommendations[_selectedMood!];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'AI Mood Check'),
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
                      'How are you feeling right now?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: _moods.map((mood) {
                        final isSelected = _selectedMood == mood['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood['value'];
                              _recommendation = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4A90E2).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4A90E2)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mood['emoji']!,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood['label']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkMood,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Get Recommendation'),
                      ),
                    ),
                    if (_recommendation != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.psychology_rounded,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'AI Recommendation',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _recommendation!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
