import 'dart:convert';

enum ScientificScale { gallupQ12, uwes, phq2, inclusion, jdR }

enum SurveyFactor {
  autonomy,
  workloadPressure,
  socialSupport,
  feedbackQuality,
  belonging,
}

class ScientificQuestion {
  const ScientificQuestion({
    required this.id,
    required this.prompt,
    required this.scale,
    required this.factor,
    this.reverseScored = false,
    this.weight = 1,
  });

  final String id;
  final String prompt;
  final ScientificScale scale;
  final SurveyFactor factor;
  final bool reverseScored;
  final double weight;
}

class QuestionResponse {
  QuestionResponse({
    required this.color,
    required this.valence,
    required this.energy,
    required this.note,
    required this.dwellTime,
  });

  final String color;
  final double valence;
  final double energy;
  final String note;
  final Duration dwellTime;

  Map<String, dynamic> toJson() => {
        'color': color,
        'valence': valence,
        'energy': energy,
        'note': note,
        'dwell_time_ms': dwellTime.inMilliseconds,
      };
}

class SurveyAggregateScore {
  SurveyAggregateScore({
    required this.burnoutRisk,
    required this.engagement,
    required this.averageEnergy,
    required this.factorScores,
    required this.recommendedActions,
    required this.sentimentScore,
    required this.attentionCheckPassed,
    required this.dominantColor,
  });

  final double burnoutRisk;
  final double engagement;
  final double averageEnergy;
  final Map<SurveyFactor, double> factorScores;
  final List<String> recommendedActions;
  final double sentimentScore;
  final bool attentionCheckPassed;
  final String dominantColor;

  Map<String, dynamic> toJson() => {
        'burnout_risk': burnoutRisk,
        'engagement': engagement,
        'average_energy': averageEnergy,
        'factor_scores': factorScores.map((k, v) => MapEntry(k.name, v)),
        'recommended_actions': recommendedActions,
        'sentiment_score': sentimentScore,
        'attention_check_passed': attentionCheckPassed,
        'dominant_color': dominantColor,
      };

  @override
  String toString() => jsonEncode(toJson());
}

const List<ScientificQuestion> scientificQuestionBank = [
  ScientificQuestion(
    id: 'gallup_q03',
    prompt: 'How included do you feel in recent team decisions?',
    scale: ScientificScale.gallupQ12,
    factor: SurveyFactor.autonomy,
  ),
  ScientificQuestion(
    id: 'jd_r_pressure',
    prompt:
        'How much pressure do current release deadlines put on your wellbeing?',
    scale: ScientificScale.jdR,
    factor: SurveyFactor.workloadPressure,
    reverseScored: true,
    weight: 1.2,
  ),
  ScientificQuestion(
    id: 'uwes_support',
    prompt: 'How often do you turn to peers for help on tasks?',
    scale: ScientificScale.uwes,
    factor: SurveyFactor.socialSupport,
  ),
  ScientificQuestion(
    id: 'feedback_timely',
    prompt: 'Do you receive timely, constructive feedback from your manager?',
    scale: ScientificScale.gallupQ12,
    factor: SurveyFactor.feedbackQuality,
  ),
  ScientificQuestion(
    id: 'belong_remote',
    prompt: 'Have you felt isolated due to remote/hybrid work?',
    scale: ScientificScale.inclusion,
    factor: SurveyFactor.belonging,
    reverseScored: true,
  ),
];
