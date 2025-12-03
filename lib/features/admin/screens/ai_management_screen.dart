import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

class AIManagementScreen extends StatefulWidget {
  const AIManagementScreen({super.key});

  @override
  State<AIManagementScreen> createState() => _AIManagementScreenState();
}

class _AIManagementScreenState extends State<AIManagementScreen> {
  final AdminService _service = AdminService();
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'AI Management Console'),
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
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.teal),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Manage AI content generation rules, scoring algorithms, and culture filters.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _CategoryTab(
                            label: 'All',
                            isSelected: _selectedCategory == 'all',
                            onTap: () =>
                                setState(() => _selectedCategory = 'all'),
                          ),
                          const SizedBox(width: 8),
                          _CategoryTab(
                            label: 'Content',
                            isSelected: _selectedCategory == 'content',
                            onTap: () =>
                                setState(() => _selectedCategory = 'content'),
                          ),
                          const SizedBox(width: 8),
                          _CategoryTab(
                            label: 'Scoring',
                            isSelected: _selectedCategory == 'scoring',
                            onTap: () =>
                                setState(() => _selectedCategory = 'scoring'),
                          ),
                          const SizedBox(width: 8),
                          _CategoryTab(
                            label: 'Recommendations',
                            isSelected: _selectedCategory == 'recommendations',
                            onTap: () => setState(
                                () => _selectedCategory = 'recommendations'),
                          ),
                          const SizedBox(width: 8),
                          _CategoryTab(
                            label: 'Filters',
                            isSelected: _selectedCategory == 'filters',
                            onTap: () =>
                                setState(() => _selectedCategory = 'filters'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // AI Settings Cards
                    _AISettingCard(
                      title: 'Content Generation Rules',
                      description:
                          'Configure how AI generates posts, summaries, and narratives',
                      category: 'content',
                      icon: Icons.article_rounded,
                      onTap: () {
                        // TODO: Navigate to content rules editor
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Content rules editor coming soon')),
                        );
                      },
                    ),
                    _AISettingCard(
                      title: 'Topic Bank (Thought Circles)',
                      description:
                          'Manage AI discussion topics and conversation starters',
                      category: 'content',
                      icon: Icons.forum_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Topic bank editor coming soon')),
                        );
                      },
                    ),
                    _AISettingCard(
                      title: 'Puzzle Difficulty Algorithm',
                      description:
                          'Adjust Brain Forge puzzle difficulty curves',
                      category: 'scoring',
                      icon: Icons.psychology_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Difficulty settings coming soon')),
                        );
                      },
                    ),
                    _AISettingCard(
                      title: 'Innovation Scoring Criteria',
                      description: 'Define how Idea Lab submissions are scored',
                      category: 'scoring',
                      icon: Icons.lightbulb_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Scoring criteria editor coming soon')),
                        );
                      },
                    ),
                    _AISettingCard(
                      title: 'Zen Activity Triggers',
                      description:
                          'Set stress level thresholds for Mind Balance recommendations',
                      category: 'recommendations',
                      icon: Icons.self_improvement_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Trigger settings coming soon')),
                        );
                      },
                    ),
                    _AISettingCard(
                      title: 'Culture Filters',
                      description: 'AI guardrails to promote positive culture',
                      category: 'filters',
                      icon: Icons.shield_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Culture filters editor coming soon')),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'AI Training Data Labels',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          _LabelOption(
                            label: 'Growth Positive',
                            description:
                                'Mark posts that promote growth and learning',
                            icon: Icons.thumb_up_rounded,
                            color: Colors.green,
                          ),
                          Divider(color: Colors.white24),
                          _LabelOption(
                            label: 'Neutral',
                            description:
                                'Standard posts with no special classification',
                            icon: Icons.remove_circle_outline_rounded,
                            color: Colors.grey,
                          ),
                          Divider(color: Colors.white24),
                          _LabelOption(
                            label: 'Avoid (Gossip/Noise)',
                            description:
                                'Flag content that doesn\'t align with culture values',
                            icon: Icons.flag_rounded,
                            color: Colors.red,
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

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.teal,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white.withOpacity(0.1),
    );
  }
}

class _AISettingCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final VoidCallback onTap;

  const _AISettingCard({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
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
                  color: Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.teal, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _LabelOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined, color: Colors.white54),
        onPressed: () {
          // TODO: Open label editor
        },
      ),
    );
  }
}
