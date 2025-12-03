import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

class MeetingGovernanceScreen extends StatelessWidget {
  const MeetingGovernanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AdminService();

    return Scaffold(
      appBar: const AppHeader(title: 'Meeting Room Governance'),
      body: FutureBuilder<List<MeetingQualityMetrics>>(
        future: service.getMeetingQualityMetrics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final metrics = snapshot.data ?? [];

          return Column(
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
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.purple),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Track meeting productivity, action item completion, and identify teams with meeting overload.',
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

                        // Team Metrics
                        const Text(
                          'Team Meeting Quality',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...metrics.map(
                            (metric) => _MeetingQualityCard(metric: metric)),

                        // Alerts Section
                        const SizedBox(height: 24),
                        const Text(
                          '⚠️ Meeting Alerts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _AlertCard(
                          title: 'Meeting Overload',
                          description:
                              'Sales team averages 8+ hours of meetings per day',
                          severity: 'warning',
                        ),
                        const _AlertCard(
                          title: 'Low Action Completion',
                          description:
                              'Engineering team has 40% pending action items',
                          severity: 'info',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const AppFooter(),
            ],
          );
        },
      ),
    );
  }
}

class _MeetingQualityCard extends StatelessWidget {
  final MeetingQualityMetrics metric;

  const _MeetingQualityCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final completionRate = metric.actionItemsCompleted /
        (metric.actionItemsCompleted + metric.actionItemsPending) *
        100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.meeting_room_rounded,
                    color: Colors.purple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.teamName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Productivity Score: ${metric.productivityScore.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total Meetings',
                    value: metric.totalMeetings.toString(),
                    icon: Icons.event_rounded,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Avg Duration',
                    value: '${metric.avgDuration.toStringAsFixed(0)} min',
                    icon: Icons.timer_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Completed',
                    value: '${metric.actionItemsCompleted}',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Pending',
                    value: '${metric.actionItemsPending}',
                    icon: Icons.pending_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Action Item Completion',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${completionRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color:
                            completionRate > 70 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionRate / 100,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionRate > 70 ? Colors.green : Colors.orange,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color ?? Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String severity;

  const _AlertCard({
    required this.title,
    required this.description,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final color = severity == 'warning' ? Colors.orange : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
