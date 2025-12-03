import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/widgets/shimmer_card.dart';
import '../../core/animations/fade_in_animation.dart';
import '../../core/utils/navigation_helper.dart';
import 'screens/learning_content_screen.dart';
import 'services/learning_service.dart';

class SkillSparksScreen extends StatefulWidget {
  const SkillSparksScreen({super.key});

  @override
  State<SkillSparksScreen> createState() => _SkillSparksScreenState();
}

class _SkillSparksScreenState extends State<SkillSparksScreen> {
  final LearningService _service = LearningService();
  List<LearningContent> _content = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await _service.getLearningContent(module: 'skill_sparks');
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id ?? 'unknown';
    const userRole = 'employee';

    return Scaffold(
      drawer: AppDrawer(userId: userId, role: userRole),
      appBar: AppHeader(
        title: 'Skill Sparks',
        showMenu: true,
        userId: userId,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: _isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: 5,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerCard(height: 100),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          FadeInAnimation(
                            delay: const Duration(milliseconds: 100),
                            child: AnimatedCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bolt_outlined,
                                      size: 32,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Skill Sparks',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Roboto',
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quick skill boosts in <3 minutes',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  fontFamily: 'Roboto',
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeInAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Your Learning Feed',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_content.isEmpty)
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 300),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      'No learning content available yet.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w300,
                                            fontFamily: 'Roboto',
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._content.map((item) => _LearningCard(
                                  content: item,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LearningContentScreen(
                                          title: item.title,
                                          category: item.category,
                                          type: item.type,
                                          content: item.content ??
                                              item.description ??
                                              'Content coming soon.',
                                        ),
                                      ),
                                    );
                                  },
                                )),
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

class _LearningCard extends StatelessWidget {
  final LearningContent content;
  final VoidCallback onTap;

  const _LearningCard({
    required this.content,
    required this.onTap,
  });

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'audio':
        return Icons.headphones_outlined;
      case 'interactive':
        return Icons.touch_app_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = content.durationMinutes != null
        ? '${content.durationMinutes} min'
        : 'Quick read';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(content.type),
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          content.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$duration • ${content.type}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
