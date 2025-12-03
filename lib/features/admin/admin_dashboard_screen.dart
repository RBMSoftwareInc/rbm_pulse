import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/widgets/shimmer_card.dart';
import '../../core/animations/fade_in_animation.dart';
import '../../core/utils/navigation_helper.dart';
import 'models/admin_models.dart';
import 'services/admin_service.dart';
import 'screens/pulse_heatmap_screen.dart';
import 'screens/culture_health_screen.dart';
import 'screens/innovation_index_screen.dart';
import 'screens/wellbeing_console_screen.dart';
import 'screens/meeting_governance_screen.dart';
import 'screens/ai_management_screen.dart';
import 'screens/post_moderation_screen.dart';
import 'screens/growth_analytics_console_screen.dart';
import 'screens/config_control_screen.dart';
import 'widgets/alert_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/ai_narrative_panel.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String userId;
  final String role;

  const AdminDashboardScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _service = AdminService();
  List<Alert> _alerts = [];
  List<TopContributor> _topContributors = [];
  String? _aiNarrative;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Map<String, dynamic> _metrics = {};

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final alerts = await _service.getAlerts();
      final contributors = await _service.getTopContributors(limit: 5);
      final narrative = await _service.getAINarrative();

      // Get real metrics
      final heatmap = await _service.getPulseHeatmap();
      final cultureTrends = await _service.getCultureHealthTrends(days: 7);
      final innovation = await _service.getInnovationIndex();
      final wellbeing = await _service.getWellbeingMetrics();

      // Calculate averages
      double avgPulseScore = 0.0;
      if (heatmap.isNotEmpty) {
        avgPulseScore = heatmap
                .map((h) =>
                    (h.avgEngagementScore + (100 - h.avgBurnoutScore)) / 2)
                .reduce((a, b) => a + b) /
            heatmap.length;
      }

      double cultureHealth = 0.0;
      if (cultureTrends.isNotEmpty) {
        cultureHealth =
            cultureTrends.map((t) => t.healthScore).reduce((a, b) => a + b) /
                cultureTrends.length;
      }

      double innovationIndex = 0.0;
      if (innovation.isNotEmpty) {
        innovationIndex =
            innovation.map((i) => i.impactScore).reduce((a, b) => a + b) /
                innovation.length;
      }

      double wellbeingScore = 0.0;
      if (wellbeing.isNotEmpty) {
        wellbeingScore = wellbeing
                .map((w) => (w.engagementScore + (100 - w.burnoutRisk)) / 2)
                .reduce((a, b) => a + b) /
            wellbeing.length;
      }

      setState(() {
        _alerts = alerts;
        _topContributors = contributors;
        _aiNarrative = narrative;
        _metrics = {
          'pulseScore': avgPulseScore,
          'cultureHealth': cultureHealth,
          'innovationIndex': innovationIndex,
          'wellbeingScore': wellbeingScore,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool _hasPermission(String feature) {
    final role = widget.role.toLowerCase();
    switch (feature) {
      case 'view_analytics':
        return role != 'employee';
      case 'manage_ai':
        return role == 'admin' || role == 'superadmin';
      case 'moderate_posts':
        return role == 'hr' || role == 'admin' || role == 'superadmin';
      case 'manage_roles':
        return role == 'hr' || role == 'admin' || role == 'superadmin';
      case 'config_control':
        return role == 'superadmin';
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Admin & Leadership Dashboard',
        showBackButton: false,
        userId: widget.userId,
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
                      itemCount: 8,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ShimmerCard(height: index < 2 ? 200 : 100),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_outlined,
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
                                          'Admin & Leadership Dashboard',
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
                                          'Role: ${widget.role}',
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
                          const SizedBox(height: 24),

                          // Alerts Section
                          if (_alerts.isNotEmpty) ...[
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                'Active Alerts',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto',
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._alerts.asMap().entries.map((entry) {
                              final index = entry.key;
                              final alert = entry.value;
                              return FadeInAnimation(
                                delay:
                                    Duration(milliseconds: 300 + (index * 100)),
                                child: AlertCard(alert: alert),
                              );
                            }),
                            const SizedBox(height: 24),
                          ],

                          // AI Narrative Panel
                          if (_aiNarrative != null) ...[
                            AINarrativePanel(narrative: _aiNarrative!),
                            const SizedBox(height: 24),
                          ],

                          // Quick Metrics
                          Text(
                            'Key Metrics',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Roboto',
                                ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              MetricCard(
                                title: 'Pulse Score',
                                value: _metrics['pulseScore'] != null
                                    ? _metrics['pulseScore'].toStringAsFixed(1)
                                    : '0.0',
                                subtitle: 'Org Average',
                                icon: Icons.assessment_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const PulseHeatmapScreen(),
                                  );
                                },
                              ),
                              MetricCard(
                                title: 'Culture Health',
                                value: _metrics['cultureHealth'] != null
                                    ? _metrics['cultureHealth']
                                        .toStringAsFixed(1)
                                    : '0.0',
                                subtitle: 'Trending Up',
                                icon: Icons.people_outline,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const CultureHealthScreen(),
                                  );
                                },
                              ),
                              MetricCard(
                                title: 'Innovation Index',
                                value: _metrics['innovationIndex'] != null
                                    ? _metrics['innovationIndex']
                                        .toStringAsFixed(1)
                                    : '0.0',
                                subtitle: 'High Impact',
                                icon: Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const InnovationIndexScreen(),
                                  );
                                },
                              ),
                              MetricCard(
                                title: 'Wellbeing Score',
                                value: _metrics['wellbeingScore'] != null
                                    ? _metrics['wellbeingScore']
                                        .toStringAsFixed(1)
                                    : '0.0',
                                subtitle: 'Monitor',
                                icon: Icons.self_improvement_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const WellbeingConsoleScreen(),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Top Contributors
                          if (_topContributors.isNotEmpty) ...[
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 900),
                              child: Text(
                                'Top Contributors',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto',
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._topContributors.asMap().entries.map((entry) {
                              final index = entry.key;
                              final contributor = entry.value;
                              return FadeInAnimation(
                                delay: Duration(
                                    milliseconds: 1000 + (index * 100)),
                                child: AnimatedCard(
                                  onTap: () {},
                                  child: _ContributorCard(
                                      contributor: contributor),
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                          ],

                          // Admin Modules
                          FadeInAnimation(
                            delay: const Duration(milliseconds: 1200),
                            child: Text(
                              'Admin Modules',
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
                          ...[
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 1300),
                              child: AnimatedCard(
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const PulseHeatmapScreen(),
                                  );
                                },
                                child: _AdminModuleCard(
                                  title: 'Pulse Score Heatmap',
                                  subtitle: 'Team → Org analytics',
                                  icon: Icons.grid_view_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 1400),
                              child: AnimatedCard(
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const CultureHealthScreen(),
                                  );
                                },
                                child: _AdminModuleCard(
                                  title: 'Culture Health Trends',
                                  subtitle: 'Engagement & sentiment',
                                  icon: Icons.trending_up_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 1500),
                              child: AnimatedCard(
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const InnovationIndexScreen(),
                                  );
                                },
                                child: _AdminModuleCard(
                                  title: 'Innovation Index',
                                  subtitle: 'Idea Lab analytics',
                                  icon: Icons.lightbulb_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 1600),
                              child: AnimatedCard(
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const WellbeingConsoleScreen(),
                                  );
                                },
                                child: _AdminModuleCard(
                                  title: 'Wellbeing Console',
                                  subtitle: 'HR wellness monitoring',
                                  icon: Icons.favorite_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 1700),
                              child: AnimatedCard(
                                onTap: () {
                                  NavigationHelper.pushSlide(
                                    context,
                                    const MeetingGovernanceScreen(),
                                  );
                                },
                                child: _AdminModuleCard(
                                  title: 'Meeting Governance',
                                  subtitle: 'Productivity & quality',
                                  icon: Icons.meeting_room_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            if (_hasPermission('moderate_posts'))
                              FadeInAnimation(
                                delay: const Duration(milliseconds: 1800),
                                child: AnimatedCard(
                                  onTap: () {
                                    NavigationHelper.pushSlide(
                                      context,
                                      const PostModerationScreen(),
                                    );
                                  },
                                  child: _AdminModuleCard(
                                    title: 'Post Moderation',
                                    subtitle: 'Content approval & spotlight',
                                    icon: Icons.flag_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            if (_hasPermission('view_analytics'))
                              FadeInAnimation(
                                delay: const Duration(milliseconds: 1900),
                                child: AnimatedCard(
                                  onTap: () {
                                    NavigationHelper.pushSlide(
                                      context,
                                      const GrowthAnalyticsConsoleScreen(),
                                    );
                                  },
                                  child: _AdminModuleCard(
                                    title: 'Growth Analytics',
                                    subtitle: 'Future Me insights',
                                    icon: Icons.auto_awesome_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            if (_hasPermission('manage_ai'))
                              FadeInAnimation(
                                delay: const Duration(milliseconds: 2000),
                                child: AnimatedCard(
                                  onTap: () {
                                    NavigationHelper.pushSlide(
                                      context,
                                      const AIManagementScreen(),
                                    );
                                  },
                                  child: _AdminModuleCard(
                                    title: 'AI Management',
                                    subtitle: 'Content & scoring rules',
                                    icon: Icons.smart_toy_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            if (_hasPermission('config_control'))
                              FadeInAnimation(
                                delay: const Duration(milliseconds: 2100),
                                child: AnimatedCard(
                                  onTap: () {
                                    NavigationHelper.pushSlide(
                                      context,
                                      const ConfigControlScreen(),
                                    );
                                  },
                                  child: _AdminModuleCard(
                                    title: 'Configuration & Control',
                                    subtitle: 'System settings',
                                    icon: Icons.settings_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: () {},
                                  ),
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

class _ContributorCard extends StatelessWidget {
  final TopContributor contributor;

  const _ContributorCard({required this.contributor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(contributor.category),
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contributor.userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contributor.achievement,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              contributor.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Roboto',
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Not used anymore, kept for compatibility
    return Colors.grey;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'skills':
        return Icons.school_outlined;
      case 'ideas':
        return Icons.lightbulb_outline;
      case 'wellness':
        return Icons.self_improvement_outlined;
      case 'meetings':
        return Icons.meeting_room_outlined;
      default:
        return Icons.star_outline;
    }
  }
}

class _AdminModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
