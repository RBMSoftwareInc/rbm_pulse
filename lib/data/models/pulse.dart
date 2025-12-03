class Pulse {
  final int? id;
  final String profileId;
  final DateTime createdAt;
  final String color;
  final int energy;
  final int stress;
  final int focusScore;
  final List<String> wellnessTags;
  final String? notes;
  final double? sentimentScore;
  final Duration responseTime;
  final bool attentionCheckPassed;
  final double? burnoutRiskScore;
  final double? engagementScore;
  final Map<String, dynamic>? questionResponses;
  final Map<String, double>? factorScores;

  Pulse({
    this.id,
    required this.profileId,
    required this.createdAt,
    required this.color,
    required this.energy,
    required this.stress,
    required this.focusScore,
    required this.wellnessTags,
    this.notes,
    this.sentimentScore,
    required this.responseTime,
    required this.attentionCheckPassed,
    this.burnoutRiskScore,
    this.engagementScore,
    this.questionResponses,
    this.factorScores,
  });

  Map<String, dynamic> toInsertMap() {
    return {
      'profile_id': profileId,
      'created_at': createdAt.toIso8601String(),
      'color': color,
      'energy': energy,
      'stress': stress,
      'focus_score': focusScore,
      'wellness_tags': wellnessTags,
      'notes': notes,
      'sentiment_score': sentimentScore,
      'response_time_ms': responseTime.inMilliseconds,
      'attention_check_passed': attentionCheckPassed,
      'burnout_risk_score': burnoutRiskScore,
      'engagement_score': engagementScore,
      'question_payload': questionResponses,
      'factor_scores': factorScores,
    };
  }
}
