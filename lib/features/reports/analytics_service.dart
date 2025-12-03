import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env/env.dart';

class PulseAnalyticsSnapshot {
  PulseAnalyticsSnapshot({
    required this.totalCheckins,
    required this.avgBurnout,
    required this.avgEngagement,
    required this.colorCounts,
    required this.departmentEnergy,
    required this.factorAverages,
    required this.riskAlerts,
  });

  final int totalCheckins;
  final double avgBurnout;
  final double avgEngagement;
  final Map<String, int> colorCounts;
  final Map<String, double> departmentEnergy;
  final Map<String, double> factorAverages;
  final List<String> riskAlerts;
}

class AnalyticsService {
  AnalyticsService();

  final SupabaseClient _client = Supabase.instance.client;

  Future<PulseAnalyticsSnapshot> fetchSummary({int limit = 400}) async {
    final List<dynamic> rows = await _client
        .from('pulses')
        .select(
            'color, energy, burnout_risk_score, engagement_score, factor_scores, profiles!inner(department)')
        .order('created_at', ascending: false)
        .limit(limit);

    final int total = rows.length;
    if (total == 0) {
      return PulseAnalyticsSnapshot(
        totalCheckins: 0,
        avgBurnout: 0,
        avgEngagement: 0,
        colorCounts: const {},
        departmentEnergy: const {},
        factorAverages: const {},
        riskAlerts: const ['No pulse data available.'],
      );
    }
    double burnoutSum = 0;
    double engagementSum = 0;

    final Map<String, int> colorCounts = {};
    final Map<String, List<double>> deptEnergyBuckets = {};
    final Map<String, int> deptCounts = {};
    final Map<String, double> factorTotals = {};
    final Map<String, int> factorCounts = {};

    for (final row in rows) {
      final color = (row['color'] ?? 'Unknown') as String;
      colorCounts[color] = (colorCounts[color] ?? 0) + 1;

      final burnout = (row['burnout_risk_score'] as num?)?.toDouble();
      final engagement = (row['engagement_score'] as num?)?.toDouble();
      if (burnout != null) burnoutSum += burnout;
      if (engagement != null) engagementSum += engagement;

      final energy = (row['energy'] as num?)?.toDouble();
      final department =
          (row['profiles']?['department'] ?? 'Unassigned') as String;

      if (energy != null) {
        deptEnergyBuckets.putIfAbsent(department, () => []).add(energy);
        deptCounts[department] = (deptCounts[department] ?? 0) + 1;
      }

      final factorMap = row['factor_scores'] as Map<String, dynamic>?;
      if (factorMap != null) {
        factorMap.forEach((key, value) {
          final score = (value as num?)?.toDouble();
          if (score == null) return;
          factorTotals[key] = (factorTotals[key] ?? 0) + score;
          factorCounts[key] = (factorCounts[key] ?? 0) + 1;
        });
      }
    }

    final departmentEnergy = <String, double>{};
    deptEnergyBuckets.forEach((dept, values) {
      final sampleSize = deptCounts[dept] ?? 0;
      if (sampleSize >= Env.minGroupSizeForAggregation) {
        final avg = values.reduce((a, b) => a + b) / values.length;
        departmentEnergy[dept] = double.parse(avg.toStringAsFixed(1));
      }
    });

    final factorAverages = factorTotals.map(
      (key, total) {
        final count = factorCounts[key] ?? 1;
        return MapEntry(
          key,
          double.parse((total / count).toStringAsFixed(1)),
        );
      },
    );

    final double avgBurnout = total == 0
        ? 0.0
        : double.parse((burnoutSum / total).toStringAsFixed(1));
    final double avgEngagement = total == 0
        ? 0.0
        : double.parse((engagementSum / total).toStringAsFixed(1));

    final riskAlerts = <String>[];
    if (avgBurnout >= 65) {
      riskAlerts.add(
          'Burnout risk trending high (${avgBurnout.toStringAsFixed(1)}).');
    }
    if (departmentEnergy.isEmpty) {
      riskAlerts.add(
          'Not enough respondents per department (min ${Env.minGroupSizeForAggregation}).');
    }
    if (factorAverages.values.any((score) => score < 50)) {
      riskAlerts.add('Multiple factors are below healthy thresholds (<50).');
    }

    return PulseAnalyticsSnapshot(
      totalCheckins: total,
      avgBurnout: avgBurnout,
      avgEngagement: avgEngagement,
      colorCounts: colorCounts,
      departmentEnergy: departmentEnergy,
      factorAverages: factorAverages,
      riskAlerts: riskAlerts,
    );
  }
}
