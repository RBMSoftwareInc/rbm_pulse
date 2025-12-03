class Profile {
  final String id;
  final String randomId;
  final String deviceId;
  final int currentStreak;
  final int longestStreak;
  final int totalCheckins;
  final double? burnoutRiskScore;
  final double? engagementScore;

  Profile({
    required this.id,
    required this.randomId,
    required this.deviceId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckins,
    this.burnoutRiskScore,
    this.engagementScore,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      randomId: map['random_id'] as String,
      deviceId: map['device_id'] as String,
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
      totalCheckins: map['total_checkins'] ?? 0,
      burnoutRiskScore: (map['burnout_risk_score'] as num?)?.toDouble(),
      engagementScore: (map['engagement_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'random_id': randomId,
      'device_id': deviceId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_checkins': totalCheckins,
      'burnout_risk_score': burnoutRiskScore,
      'engagement_score': engagementScore,
    };
  }
}
