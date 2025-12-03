import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

class WellbeingConsoleScreen extends StatefulWidget {
  const WellbeingConsoleScreen({super.key});

  @override
  State<WellbeingConsoleScreen> createState() => _WellbeingConsoleScreenState();
}

class _WellbeingConsoleScreenState extends State<WellbeingConsoleScreen> {
  final AdminService _service = AdminService();
  List<WellbeingMetrics> _metrics = [];
  String _filterRiskLevel = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getWellbeingMetrics(
        riskLevel: _filterRiskLevel == 'all' ? null : _filterRiskLevel,
      );
      setState(() {
        _metrics = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Employee Wellbeing Console'),
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
              child: Column(
                children: [
                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _filterRiskLevel == 'all',
                            onTap: () {
                              setState(() => _filterRiskLevel = 'all');
                              _loadData();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Low Risk',
                            isSelected: _filterRiskLevel == 'low',
                            color: Colors.green,
                            onTap: () {
                              setState(() => _filterRiskLevel = 'low');
                              _loadData();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Moderate',
                            isSelected: _filterRiskLevel == 'moderate',
                            color: Colors.orange,
                            onTap: () {
                              setState(() => _filterRiskLevel = 'moderate');
                              _loadData();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'High Risk',
                            isSelected: _filterRiskLevel == 'high',
                            color: Colors.red,
                            onTap: () {
                              setState(() => _filterRiskLevel = 'high');
                              _loadData();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Critical',
                            isSelected: _filterRiskLevel == 'critical',
                            color: Colors.red.shade900,
                            onTap: () {
                              setState(() => _filterRiskLevel = 'critical');
                              _loadData();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Metrics List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _metrics.isEmpty
                            ? Center(
                                child: Text(
                                  'No data available',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _metrics.length,
                                itemBuilder: (context, index) {
                                  final metric = _metrics[index];
                                  return _WellbeingCard(metric: metric);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color ?? Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white.withOpacity(0.1),
    );
  }
}

class _WellbeingCard extends StatelessWidget {
  final WellbeingMetrics metric;

  const _WellbeingCard({required this.metric});

  Color _getRiskColor() {
    switch (metric.riskLevel) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getRiskColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: _getRiskColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        metric.department,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    metric.riskLevel.toUpperCase(),
                    style: TextStyle(
                      color: _getRiskColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: 'Burnout Risk',
                    value: '${metric.burnoutRisk.toStringAsFixed(1)}%',
                    color: metric.burnoutRisk > 60 ? Colors.red : Colors.orange,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    label: 'Engagement',
                    value: '${metric.engagementScore.toStringAsFixed(1)}%',
                    color: metric.engagementScore > 70
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: 'Zen Streak',
                    value: '${metric.mindBalanceStreak} days',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    label: 'Focus',
                    value: '${metric.focusConsistency.toStringAsFixed(1)}%',
                    color: metric.focusConsistency > 70
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getInterventionSuggestion(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInterventionSuggestion() {
    if (metric.riskLevel == 'critical' || metric.riskLevel == 'high') {
      return 'Consider: Coaching session, additional break reminders, recognition support';
    } else if (metric.riskLevel == 'moderate') {
      return 'Monitor: Encourage Mind Balance activities, celebrate progress';
    } else {
      return 'Status: Healthy - Continue current wellness practices';
    }
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
