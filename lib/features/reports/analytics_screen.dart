import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/app_drawer.dart';
import 'analytics_service.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final AnalyticsService _service = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get user info for drawer
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id ?? 'unknown';
    const userRole = 'hr'; // Analytics is typically for HR/admin

    return Scaffold(
      drawer: AppDrawer(
        userId: userId,
        role: userRole,
      ),
      appBar: const AppHeader(
        title: 'Team Pulse Analytics',
        showMenu: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<PulseAnalyticsSnapshot>(
              future: _service.fetchSummary(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final report = snapshot.data!;
                final colorLabels = report.colorCounts.keys.toList();
                final colorVals = report.colorCounts.values.toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.assessment_outlined,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Check-ins',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${report.totalCheckins}',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Burnout: ${report.avgBurnout.toStringAsFixed(1)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  Text(
                                    'Engagement: ${report.avgEngagement.toStringAsFixed(1)}',
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
                      ),
                      if (report.riskAlerts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning_outlined,
                                      color: theme.colorScheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Alerts',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Roboto',
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...report.riskAlerts.map(
                                  (alert) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 6, right: 8),
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.error,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            alert,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w300,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text('Mood Colors Distribution',
                          style: theme.textTheme.titleMedium),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: List.generate(
                              colorLabels.length,
                              (i) => PieChartSectionData(
                                color: _mapColor(colorLabels[i]),
                                value: colorVals[i].toDouble(),
                                title: '${colorLabels[i]} (${colorVals[i]})',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                radius: 65,
                              ),
                            ),
                            sectionsSpace: 3,
                            centerSpaceRadius: 32,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      _buildLegend(),
                      const SizedBox(height: 28),
                      Text('Department Energy',
                          style: theme.textTheme.titleMedium),
                      SizedBox(
                        height: 170,
                        child: report.departmentEnergy.isEmpty
                            ? const Text(
                                "No department data available",
                                style: TextStyle(color: Colors.white70),
                              )
                            : BarChart(
                                BarChartData(
                                  barGroups: report.departmentEnergy.entries
                                      .map(
                                        (entry) => BarChartGroupData(
                                          x: report.departmentEnergy.keys
                                              .toList()
                                              .indexOf(entry.key),
                                          barRods: [
                                            BarChartRodData(
                                              toY: entry.value,
                                              color: Colors.greenAccent,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              backDrawRodData:
                                                  BackgroundBarChartRodData(
                                                show: true,
                                                toY: 100,
                                                color: Colors.white10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index <
                                              report.departmentEnergy.keys
                                                  .length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 6.0),
                                              child: Text(
                                                report.departmentEnergy.keys
                                                    .elementAt(index),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  barTouchData: BarTouchData(enabled: true),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Factor Health',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: report.factorAverages.isEmpty
                              ? Text(
                                  'No factor data captured yet.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'Roboto',
                                  ),
                                )
                              : Column(
                                  children: report.factorAverages.entries
                                      .map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    entry.key,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                  Text(
                                                    '${entry.value.toStringAsFixed(1)}%',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      fontWeight: FontWeight.w300,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              LinearProgressIndicator(
                                                value: entry.value / 100,
                                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  entry.value >= 60
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme.error,
                                                ),
                                                minHeight: 6,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recent Pulse Trends',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pulse chart examples and more detailed analytics can be added here as you expand reporting capabilities.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

Widget _buildLegend() => const Card(
      color: Colors.black,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color Legend:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            _LegendRow(Color(0xFFD72631), 'Red: High stress/burnout'),
            _LegendRow(Color(0xFF00A86B), 'Green: High engagement'),
            _LegendRow(Color(0xFF0F52BA), 'Blue: Calm/focused'),
            _LegendRow(Color(0xFFFFEA00), 'Yellow: Alert/active'),
            _LegendRow(Color(0xFFE75480), 'Pink: Sensitive/emotional'),
          ],
        ),
      ),
    );

class _LegendRow extends StatelessWidget {
  const _LegendRow(this.color, this.text);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 8),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

Color _mapColor(String name) {
  switch (name) {
    case 'Red':
      return const Color(0xFFD72631);
    case 'Green':
      return const Color(0xFF00A86B);
    case 'Blue':
      return const Color(0xFF0F52BA);
    case 'Yellow':
      return const Color(0xFFFFEA00);
    case 'Orange':
      return const Color(0xFFFFA500);
    case 'Purple':
      return const Color(0xFF6A0DAD);
    case 'Grey':
      return const Color(0xFF7D7D7D);
    case 'Pink':
      return const Color(0xFFE75480);
    default:
      return Colors.grey;
  }
}
