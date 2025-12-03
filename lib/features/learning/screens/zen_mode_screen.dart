import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import 'zen_activity_screen.dart';
import 'zen_progress_screen.dart';

class ZenModeScreen extends StatelessWidget {
  const ZenModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Zen Mode'),
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
                          colors: [Color(0xFF2D5016), Color(0xFF4A7C2A)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.self_improvement_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zen Activity Library',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Short, effective wellness routines',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.emoji_events_rounded,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ZenProgressScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category: Quick Mindfulness Practices
                    _buildCategory(
                      context,
                      title: '🧘 Quick Mindfulness Practices',
                      activities: [
                        ZenActivity(
                          id: 'breathing_reset',
                          title: 'Breathing Reset',
                          description: 'Inhale 4s, hold 2s, exhale 6s',
                          icon: Icons.air_rounded,
                          duration: '2 min',
                          category: 'mindfulness',
                        ),
                        ZenActivity(
                          id: 'box_breathing',
                          title: 'Box Breathing',
                          description: '4×4×4×4 calm cycle',
                          icon: Icons.crop_square_rounded,
                          duration: '3 min',
                          category: 'mindfulness',
                        ),
                        ZenActivity(
                          id: 'mindful_sitting',
                          title: 'Mindful Sitting',
                          description: 'Feel the seat, spine straight',
                          icon: Icons.chair_rounded,
                          duration: '5 min',
                          category: 'mindfulness',
                        ),
                        ZenActivity(
                          id: 'grounding_54321',
                          title: '5-4-3-2-1 Grounding',
                          description: 'Use senses to reset anxiety',
                          icon: Icons.anchor_rounded,
                          duration: '3 min',
                          category: 'mindfulness',
                        ),
                        ZenActivity(
                          id: 'thought_cloud',
                          title: 'Thought Cloud Visualization',
                          description: 'Observe thoughts floating away',
                          icon: Icons.cloud_rounded,
                          duration: '4 min',
                          category: 'mindfulness',
                        ),
                      ],
                    ),

                    // Category: Eye & Screen Fatigue Relief
                    _buildCategory(
                      context,
                      title: '👁️ Eye & Screen Fatigue Relief',
                      activities: [
                        ZenActivity(
                          id: '20_20_20_rule',
                          title: '20-20-20 Rule',
                          description: '20s focus on 20ft distance',
                          icon: Icons.remove_red_eye_rounded,
                          duration: '1 min',
                          category: 'eye_care',
                        ),
                        ZenActivity(
                          id: 'blink_relax',
                          title: 'Blink & Relax',
                          description: 'Reduce dryness',
                          icon: Icons.visibility_rounded,
                          duration: '30 sec',
                          category: 'eye_care',
                        ),
                        ZenActivity(
                          id: 'palm_massage',
                          title: 'Palm Warm Massage',
                          description: 'Warmth therapy for eyes',
                          icon: Icons.wb_sunny_rounded,
                          duration: '2 min',
                          category: 'eye_care',
                        ),
                        ZenActivity(
                          id: 'figure_8_eyes',
                          title: 'Figure-8 Eye Movement',
                          description: 'Improves muscle flexibility',
                          icon: Icons.auto_fix_high_rounded,
                          duration: '2 min',
                          category: 'eye_care',
                        ),
                      ],
                    ),

                    // Category: Stress & Tension Release
                    _buildCategory(
                      context,
                      title: '🌬️ Stress & Tension Release',
                      activities: [
                        ZenActivity(
                          id: 'jaw_relaxation',
                          title: 'Jaw Relaxation Routine',
                          description: 'Release clenching stress',
                          icon: Icons.sentiment_satisfied_rounded,
                          duration: '3 min',
                          category: 'stress_relief',
                        ),
                        ZenActivity(
                          id: 'neck_shoulder_drop',
                          title: 'Neck & Shoulder Drop',
                          description: 'Dissolve upper-body tension',
                          icon: Icons.accessibility_new_rounded,
                          duration: '4 min',
                          category: 'stress_relief',
                        ),
                        ZenActivity(
                          id: 'finger_palm_stretch',
                          title: 'Finger + Palm Stretch',
                          description: 'Keyboard strain remedy',
                          icon: Icons.back_hand_rounded,
                          duration: '2 min',
                          category: 'stress_relief',
                        ),
                        ZenActivity(
                          id: 'back_roll',
                          title: 'Back Roll Micro-stretch',
                          description: 'Done at desk',
                          icon: Icons.airline_seat_flat_rounded,
                          duration: '3 min',
                          category: 'stress_relief',
                        ),
                      ],
                    ),

                    // Category: Audio-Only Calm Moments
                    _buildCategory(
                      context,
                      title: '🎧 Audio-Only Calm Moments',
                      activities: [
                        ZenActivity(
                          id: 'zen_bell_60s',
                          title: '60-Second Zen Bell',
                          description: 'Peaceful bell meditation',
                          icon: Icons.music_note_rounded,
                          duration: '1 min',
                          category: 'audio',
                        ),
                        ZenActivity(
                          id: 'nature_sounds',
                          title: 'Soothing Nature Clip',
                          description: 'Rain / river / wind',
                          icon: Icons.water_drop_rounded,
                          duration: '3 min',
                          category: 'audio',
                        ),
                        ZenActivity(
                          id: 'healing_frequency',
                          title: 'Healing Frequency',
                          description: '432 Hz calm focus',
                          icon: Icons.graphic_eq_rounded,
                          duration: '5 min',
                          category: 'audio',
                        ),
                        ZenActivity(
                          id: 'guided_micro_meditation',
                          title: 'Guided Micro Meditation',
                          description: 'One positive sentence',
                          icon: Icons.record_voice_over_rounded,
                          duration: '2 min',
                          category: 'audio',
                        ),
                      ],
                    ),

                    // Category: Cognitive Mindfulness
                    _buildCategory(
                      context,
                      title: '🧠 Cognitive Mindfulness',
                      activities: [
                        ZenActivity(
                          id: 'single_task_focus',
                          title: 'Single-Task Focus Ritual',
                          description: 'Do one task intentionally',
                          icon: Icons.center_focus_strong_rounded,
                          duration: '5 min',
                          category: 'cognitive',
                        ),
                        ZenActivity(
                          id: 'breath_counting',
                          title: 'Breath Counting',
                          description: 'Anchor attention',
                          icon: Icons.filter_1_rounded,
                          duration: '3 min',
                          category: 'cognitive',
                        ),
                        ZenActivity(
                          id: 'awareness_check',
                          title: 'Awareness Check',
                          description: 'What am I feeling right now?',
                          icon: Icons.psychology_rounded,
                          duration: '2 min',
                          category: 'cognitive',
                        ),
                        ZenActivity(
                          id: 'mindful_micro_pause',
                          title: 'Mindful Micro-Pause',
                          description: 'Before starting next task',
                          icon: Icons.pause_circle_rounded,
                          duration: '1 min',
                          category: 'cognitive',
                        ),
                      ],
                    ),

                    // Category: Emotional Well-being
                    _buildCategory(
                      context,
                      title: '❤️ Emotional Well-being',
                      activities: [
                        ZenActivity(
                          id: 'gratitude_flash',
                          title: 'Gratitude Flash',
                          description: '1 person or thing you\'re thankful for',
                          icon: Icons.favorite_rounded,
                          duration: '1 min',
                          category: 'emotional',
                        ),
                        ZenActivity(
                          id: 'compliment_someone',
                          title: 'Compliment Someone',
                          description: 'Instant positivity ripple',
                          icon: Icons.thumb_up_rounded,
                          duration: '2 min',
                          category: 'emotional',
                        ),
                        ZenActivity(
                          id: 'self_compassion',
                          title: 'Self-Compassion Break',
                          description: 'I am learning, growing',
                          icon: Icons.spa_rounded,
                          duration: '3 min',
                          category: 'emotional',
                        ),
                        ZenActivity(
                          id: 'let_it_go',
                          title: 'Let-It-Go Ritual',
                          description: 'Drop one thought intentionally',
                          icon: Icons.wb_twilight_rounded,
                          duration: '2 min',
                          category: 'emotional',
                        ),
                      ],
                    ),

                    // Category: Healthy Work Rhythm
                    _buildCategory(
                      context,
                      title: '🔔 Healthy Work Rhythm',
                      activities: [
                        ZenActivity(
                          id: 'hydration_reminder',
                          title: 'Hydration Reminder',
                          description: 'Sip water with presence',
                          icon: Icons.water_drop_rounded,
                          duration: '1 min',
                          category: 'work_rhythm',
                        ),
                        ZenActivity(
                          id: 'deep_yawn_stretch',
                          title: 'Deep Yawn + Stretch',
                          description: 'Refresh oxygen',
                          icon: Icons.air_rounded,
                          duration: '1 min',
                          category: 'work_rhythm',
                        ),
                        ZenActivity(
                          id: 'stand_reset',
                          title: 'Stand & Reset',
                          description: '30 sec posture correction',
                          icon: Icons.accessible_forward_rounded,
                          duration: '1 min',
                          category: 'work_rhythm',
                        ),
                        ZenActivity(
                          id: 'micro_walk',
                          title: 'Micro Walk Loop',
                          description: '1 min around desk',
                          icon: Icons.directions_walk_rounded,
                          duration: '1 min',
                          category: 'work_rhythm',
                        ),
                        ZenActivity(
                          id: 'digital_sunset',
                          title: 'Digital Sunset Prompt',
                          description: 'Reduce late blue light exposure',
                          icon: Icons.brightness_2_rounded,
                          duration: '1 min',
                          category: 'work_rhythm',
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

  Widget _buildCategory(
    BuildContext context, {
    required String title,
    required List<ZenActivity> activities,
  }) {
    return Column(
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
        const SizedBox(height: 12),
        ...activities.map((activity) => _ZenActivityCard(
              activity: activity,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZenActivityScreen(activity: activity),
                  ),
                );
              },
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ZenActivity {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String duration;
  final String category;

  ZenActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
    required this.category,
  });
}

class _ZenActivityCard extends StatelessWidget {
  final ZenActivity activity;
  final VoidCallback onTap;

  const _ZenActivityCard({
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activity.icon,
                  color: _getCategoryColor(activity.category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getCategoryColor(activity.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity.duration,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getCategoryColor(activity.category),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white54,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'mindfulness':
        return const Color(0xFF4A90E2);
      case 'eye_care':
        return const Color(0xFF7B68EE);
      case 'stress_relief':
        return const Color(0xFFE74C3C);
      case 'audio':
        return const Color(0xFF9B59B6);
      case 'cognitive':
        return const Color(0xFFF39C12);
      case 'emotional':
        return const Color(0xFFE91E63);
      case 'work_rhythm':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF4A90E2);
    }
  }
}
