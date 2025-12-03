import 'dart:math';

import '../models/scientific_question.dart';

class SurveyScoringService {
  const SurveyScoringService();

  SurveyAggregateScore score({
    required List<ScientificQuestion> questions,
    required Map<String, QuestionResponse> responses,
  }) {
    double burnoutAccumulator = 0;
    double burnoutWeights = 0;
    double engagementAccumulator = 0;
    double engagementWeights = 0;
    double energyAccumulator = 0;

    final Map<SurveyFactor, double> factorTotals = {};
    final Map<SurveyFactor, double> factorWeights = {};
    final Map<String, int> colorCounts = {};

    Duration dwellAccumulator = Duration.zero;

    for (final entry in responses.entries) {
      final question = questions.firstWhere(
        (q) => q.id == entry.key,
        orElse: () => throw ArgumentError('Unknown question id ${entry.key}'),
      );
      final response = entry.value;

      final normalizedValence = response.valence / 100;
      final normalizedEnergy = response.energy / 100;
      final valenceScore =
          question.reverseScored ? (1 - normalizedValence) : normalizedValence;

      final factorScore = ((valenceScore * 0.6) + (normalizedEnergy * 0.4)) *
          100 *
          question.weight;

      factorTotals[question.factor] =
          (factorTotals[question.factor] ?? 0) + factorScore;
      factorWeights[question.factor] =
          (factorWeights[question.factor] ?? 0) + question.weight;

      if (_isDemand(question.factor)) {
        burnoutAccumulator += factorScore;
        burnoutWeights += question.weight;
      } else {
        engagementAccumulator += factorScore;
        engagementWeights += question.weight;
      }

      energyAccumulator += response.energy;
      dwellAccumulator += response.dwellTime;
      colorCounts[response.color] = (colorCounts[response.color] ?? 0) + 1;
    }

    final double averageEnergy =
        responses.isEmpty ? 50.0 : energyAccumulator / responses.length;
    final double burnoutRisk =
        burnoutWeights == 0 ? 0.0 : (burnoutAccumulator / burnoutWeights);
    final double engagement = engagementWeights == 0
        ? 0.0
        : (engagementAccumulator / engagementWeights);

    final dominantColor = colorCounts.entries.isEmpty
        ? 'Green'
        : colorCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final colorPenalty = _colorPenalty(dominantColor);
    final burnoutWithPenalty = max(
      0.0,
      min(100.0, burnoutRisk + colorPenalty - averageEnergy * 0.2),
    );

    final sentimentScore = _sentimentFromNotes(responses.values);
    final attentionCheckPassed =
        _attentionCheck(responses.values, dwellAccumulator);

    final recommendedActions =
        _buildRecommendations(factorTotals, factorWeights, averageEnergy);

    return SurveyAggregateScore(
      burnoutRisk: double.parse(burnoutWithPenalty.toStringAsFixed(1)),
      engagement: double.parse(
        min(100.0, engagement + sentimentScore * 5).toStringAsFixed(1),
      ),
      averageEnergy: double.parse(averageEnergy.toStringAsFixed(1)),
      factorScores: factorTotals.map(
        (factor, total) {
          final double denominator = factorWeights[factor] ?? 1.0;
          return MapEntry(factor, total / denominator);
        },
      ),
      recommendedActions: recommendedActions,
      sentimentScore: sentimentScore,
      attentionCheckPassed: attentionCheckPassed,
      dominantColor: dominantColor,
    );
  }

  bool _isDemand(SurveyFactor factor) =>
      factor == SurveyFactor.workloadPressure ||
      factor == SurveyFactor.belonging;

  double _colorPenalty(String color) {
    switch (color) {
      case 'Red':
        return 18;
      case 'Orange':
        return 12;
      case 'Grey':
      case 'Purple':
        return 8;
      case 'Yellow':
        return 5;
      default:
        return -4;
    }
  }

  double _sentimentFromNotes(Iterable<QuestionResponse> responses) {
    final positiveLexicon = {'grateful', 'supported', 'progress', 'learning'};
    final negativeLexicon = {'stressed', 'burnout', 'alone', 'blocked'};
    int positiveHits = 0;
    int negativeHits = 0;
    for (final response in responses) {
      final text = response.note.toLowerCase();
      for (final word in positiveLexicon) {
        if (text.contains(word)) positiveHits++;
      }
      for (final word in negativeLexicon) {
        if (text.contains(word)) negativeHits++;
      }
    }
    if (positiveHits == 0 && negativeHits == 0) return 0;
    final total = positiveHits + negativeHits;
    return ((positiveHits - negativeHits) / total).clamp(-1, 1).toDouble();
  }

  bool _attentionCheck(
    Iterable<QuestionResponse> responses,
    Duration dwellAccumulator,
  ) {
    if (responses.isEmpty) return true;
    final avgDwell = dwellAccumulator.inMilliseconds / responses.length;
    final distinctColors = responses.map((e) => e.color).toSet().length;
    return avgDwell > 2000 && distinctColors > 1;
  }

  List<String> _buildRecommendations(
    Map<SurveyFactor, double> factorTotals,
    Map<SurveyFactor, double> factorWeights,
    double averageEnergy,
  ) {
    final List<String> recommendations = [];
    factorTotals.forEach((factor, total) {
      final score = total / (factorWeights[factor] ?? 1);
      if (score < 55) {
        switch (factor) {
          case SurveyFactor.autonomy:
            recommendations
                .add('Clarify decision latitude and prioritise focus time.');
            break;
          case SurveyFactor.workloadPressure:
            recommendations.add('Rebalance sprint scope or add recovery days.');
            break;
          case SurveyFactor.socialSupport:
            recommendations.add('Schedule peer coaching or buddy syncs.');
            break;
          case SurveyFactor.feedbackQuality:
            recommendations
                .add('Book tactical feedback loops with your manager.');
            break;
          case SurveyFactor.belonging:
            recommendations.add('Plan inclusive rituals for hybrid teammates.');
            break;
        }
      }
    });
    if (averageEnergy < 45) {
      recommendations.add('Suggest micro-breaks or energy audits this week.');
    }
    return recommendations.take(5).toList();
  }
}
