import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/growth_data.dart';

/// Service for managing growth data and predictions
/// Uses Supabase for data persistence
class GrowthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current growth metrics (aggregated from all modules)
  Future<GrowthMetrics> getGrowthMetrics(String userId) async {
    try {
      // Get latest snapshot
      final snapshot = await _supabase
          .from('growth_snapshots')
          .select()
          .eq('user_id', userId)
          .order('snapshot_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (snapshot != null) {
        return GrowthMetrics(
          skillSparksScore: (snapshot['skill_sparks_score'] as num?)?.toDouble() ?? 0.0,
          brainForgeScore: (snapshot['brain_forge_score'] as num?)?.toDouble() ?? 0.0,
          mindBalanceStreak: (snapshot['mind_balance_streak'] as num?)?.toDouble() ?? 0.0,
          focusZoneDiscipline: (snapshot['focus_zone_discipline'] as num?)?.toDouble() ?? 0.0,
          thoughtCirclesParticipation: (snapshot['thought_circles_participation'] as num?)?.toDouble() ?? 0.0,
          ideaLabImpactScore: (snapshot['idea_lab_impact_score'] as num?)?.toDouble() ?? 0.0,
          meetingRoomContribution: (snapshot['meeting_room_contribution'] as num?)?.toDouble() ?? 0.0,
        );
      }

      // If no snapshot, calculate from activities
      return await _calculateMetricsFromActivities(userId);
    } catch (e) {
      return await _calculateMetricsFromActivities(userId);
    }
  }

  /// Calculate metrics from various activity sources
  Future<GrowthMetrics> _calculateMetricsFromActivities(String userId) async {
    double skillSparks = 0.0;
    double brainForge = 0.0;
    double mindBalanceStreak = 0.0;
    double focusZone = 0.0;
    double thoughtCircles = 0.0;
    double ideaLab = 0.0;
    double meetingRoom = 0.0;

    try {
      // Skill Sparks
      final skillSparksData = await _supabase
          .from('learning_activities')
          .select('score')
          .eq('user_id', userId)
          .eq('module', 'skill_sparks')
          .order('created_at', ascending: false)
          .limit(10);

      if (skillSparksData.isNotEmpty) {
        skillSparks = skillSparksData
            .map((e) => (e['score'] as num?)?.toDouble() ?? 0.0)
            .reduce((a, b) => a + b) /
            skillSparksData.length;
      }
    } catch (_) {}

    try {
      // Brain Forge
      final brainForgeData = await _supabase
          .from('learning_activities')
          .select('score')
          .eq('user_id', userId)
          .eq('module', 'brain_forge')
          .order('created_at', ascending: false)
          .limit(10);

      if (brainForgeData.isNotEmpty) {
        brainForge = brainForgeData
            .map((e) => (e['score'] as num?)?.toDouble() ?? 0.0)
            .reduce((a, b) => a + b) /
            brainForgeData.length;
      }
    } catch (_) {}

    try {
      // Mind Balance Streak
      final zenActivities = await _supabase
          .from('zen_activities')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      mindBalanceStreak = zenActivities.length.toDouble();
    } catch (_) {}

    try {
      // Focus Zone
      final focusSessions = await _supabase
          .from('focus_sessions')
          .select('duration_minutes')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      if (focusSessions.isNotEmpty) {
        focusZone = focusSessions
            .map((e) => (e['duration_minutes'] as num?)?.toDouble() ?? 0.0)
            .reduce((a, b) => a + b) /
            focusSessions.length;
      }
    } catch (_) {}

    try {
      // Thought Circles
      final discussions = await _supabase
          .from('discussion_participations')
          .select('id')
          .eq('user_id', userId) as List;

      thoughtCircles = discussions.length.toDouble();
    } catch (_) {}

    try {
      // Idea Lab
      final ideas = await _supabase
          .from('idea_submissions')
          .select('impact_score')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      if (ideas.isNotEmpty) {
        ideaLab = ideas
            .map((e) => (e['impact_score'] as num?)?.toDouble() ?? 0.0)
            .reduce((a, b) => a + b) /
            ideas.length;
      }
    } catch (_) {}

    try {
      // Meeting Room
      final meetings = await _supabase
          .from('meetings')
          .select('id')
          .eq('organizer_id', userId) as List;

      meetingRoom = meetings.length.toDouble();
    } catch (_) {}

    return GrowthMetrics(
      skillSparksScore: skillSparks,
      brainForgeScore: brainForge,
      mindBalanceStreak: mindBalanceStreak,
      focusZoneDiscipline: focusZone,
      thoughtCirclesParticipation: thoughtCircles,
      ideaLabImpactScore: ideaLab,
      meetingRoomContribution: meetingRoom,
    );
  }

  /// Get growth prediction (from database or calculate)
  Future<GrowthPrediction> getGrowthPrediction(
    String userId,
    GrowthMetrics metrics,
  ) async {
    try {
      // Try to get existing prediction
      final prediction = await _supabase
          .from('growth_predictions')
          .select()
          .eq('user_id', userId)
          .order('generated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (prediction != null) {
        return GrowthPrediction(
          currentRating: (prediction['current_rating'] as num).toDouble(),
          predictedRating3Months:
              (prediction['predicted_3_months'] as num?)?.toDouble() ?? 0.0,
          predictedRating6Months:
              (prediction['predicted_6_months'] as num?)?.toDouble() ?? 0.0,
          predictedRating12Months:
              (prediction['predicted_12_months'] as num?)?.toDouble() ?? 0.0,
          recommendedActions: _generateRecommendations(metrics),
          motivationalMessage: prediction['motivational_message'] as String? ??
              _generateMotivationalMessage(metrics.futureGrowthRating),
        );
      }

      // Calculate new prediction
      final currentRating = metrics.futureGrowthRating;
      final growthRate = _calculateGrowthRate(userId, metrics);

      final newPrediction = GrowthPrediction(
        currentRating: currentRating,
        predictedRating3Months: (currentRating * (1 + growthRate)).clamp(0.0, 100.0),
        predictedRating6Months: (currentRating * (1 + growthRate * 2)).clamp(0.0, 100.0),
        predictedRating12Months: (currentRating * (1 + growthRate * 4)).clamp(0.0, 100.0),
        recommendedActions: _generateRecommendations(metrics),
        motivationalMessage: _generateMotivationalMessage(currentRating),
      );

      // Save prediction
      await _supabase.from('growth_predictions').upsert({
        'user_id': userId,
        'current_rating': currentRating,
        'predicted_3_months': newPrediction.predictedRating3Months,
        'predicted_6_months': newPrediction.predictedRating6Months,
        'predicted_12_months': newPrediction.predictedRating12Months,
        'motivational_message': newPrediction.motivationalMessage,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return newPrediction;
    } catch (e) {
      // Fallback calculation
      final currentRating = metrics.futureGrowthRating;
      return GrowthPrediction(
        currentRating: currentRating,
        predictedRating3Months: (currentRating * 1.15).clamp(0.0, 100.0),
        predictedRating6Months: (currentRating * 1.30).clamp(0.0, 100.0),
        predictedRating12Months: (currentRating * 1.60).clamp(0.0, 100.0),
        recommendedActions: _generateRecommendations(metrics),
        motivationalMessage: _generateMotivationalMessage(currentRating),
      );
    }
  }

  double _calculateGrowthRate(String userId, GrowthMetrics metrics) {
    // Calculate growth rate based on recent activity trends
    // Simplified: use average of all metrics
    final avgScore = (metrics.skillSparksScore +
            metrics.brainForgeScore +
            metrics.focusZoneDiscipline +
            metrics.ideaLabImpactScore) /
        4.0;

    // Higher scores = higher growth potential
    if (avgScore > 80) return 0.20; // 20% growth
    if (avgScore > 60) return 0.15; // 15% growth
    if (avgScore > 40) return 0.10; // 10% growth
    return 0.05; // 5% growth
  }

  /// Get skill tree nodes
  Future<List<SkillNode>> getSkillTree(String userId) async {
    try {
      final response = await _supabase
          .from('skill_nodes')
          .select('''
            *,
            skill_node_connections!from_node_id(to_node_id)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (response as List).map((json) => _skillNodeFromJson(json)).toList();
    } catch (e) {
      // Return default skill tree if none exists
      return _getDefaultSkillTree();
    }
  }

  /// Get weekly challenges
  Future<List<WeeklyChallenge>> getWeeklyChallenges(String userId) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from('weekly_challenges')
          .select()
          .eq('user_id', userId)
          .gte('end_date', now.toIso8601String())
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => _weeklyChallengeFromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Create weekly challenge
  Future<WeeklyChallenge> createWeeklyChallenge({
    required String userId,
    required String title,
    String? description,
    required String category,
    required double targetScore,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('weekly_challenges')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'category': category,
            'target_score': targetScore,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
          })
          .select()
          .single();

      return _weeklyChallengeFromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(
    String challengeId,
    double progress,
  ) async {
    try {
      await _supabase
          .from('weekly_challenges')
          .update({
            'current_progress': progress,
            'is_completed': progress >= 100.0,
            'completed_at': progress >= 100.0 ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', challengeId);
    } catch (e) {
      rethrow;
    }
  }

  /// Save growth snapshot
  Future<void> saveGrowthSnapshot(String userId, GrowthMetrics metrics) async {
    try {
      await _supabase.from('growth_snapshots').upsert({
        'user_id': userId,
        'skill_sparks_score': metrics.skillSparksScore,
        'brain_forge_score': metrics.brainForgeScore,
        'mind_balance_streak': metrics.mindBalanceStreak.toInt(),
        'focus_zone_discipline': metrics.focusZoneDiscipline,
        'thought_circles_participation': metrics.thoughtCirclesParticipation,
        'idea_lab_impact_score': metrics.ideaLabImpactScore,
        'meeting_room_contribution': metrics.meetingRoomContribution,
        'future_growth_rating': metrics.futureGrowthRating,
        'snapshot_date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore errors
    }
  }

  List<SkillNode> _getDefaultSkillTree() {
    return [
      SkillNode(
        id: 'core1',
        name: 'Technical Skills',
        category: 'skill',
        level: 0.0,
        connectedNodeIds: ['core2', 'core3'],
        isMastered: false,
      ),
      SkillNode(
        id: 'core2',
        name: 'Communication',
        category: 'collaboration',
        level: 0.0,
        connectedNodeIds: ['core1', 'core4'],
        isMastered: false,
      ),
      SkillNode(
        id: 'core3',
        name: 'Problem Solving',
        category: 'cognitive',
        level: 0.0,
        connectedNodeIds: ['core1', 'core5'],
        isMastered: false,
      ),
      SkillNode(
        id: 'core4',
        name: 'Emotional Intelligence',
        category: 'wellbeing',
        level: 0.0,
        connectedNodeIds: ['core2', 'core6'],
        isMastered: false,
      ),
      SkillNode(
        id: 'core5',
        name: 'Critical Thinking',
        category: 'cognitive',
        level: 0.0,
        connectedNodeIds: ['core3'],
        isMastered: false,
      ),
      SkillNode(
        id: 'core6',
        name: 'Stress Management',
        category: 'wellbeing',
        level: 0.0,
        connectedNodeIds: ['core4'],
        isMastered: false,
      ),
    ];
  }

  SkillNode _skillNodeFromJson(Map<String, dynamic> json) {
    final connections = json['skill_node_connections'] as List? ?? [];
    final connectedIds = connections
        .map((c) => c['to_node_id'] as String)
        .toList();

    return SkillNode(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
      connectedNodeIds: connectedIds,
      isMastered: json['is_mastered'] as bool? ?? false,
    );
  }

  WeeklyChallenge _weeklyChallengeFromJson(Map<String, dynamic> json) {
    return WeeklyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      targetScore: (json['target_score'] as num).toDouble(),
      currentProgress: (json['current_progress'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  List<String> _generateRecommendations(GrowthMetrics metrics) {
    final recommendations = <String>[];

    if (metrics.skillSparksScore < 50) {
      recommendations.add('Complete more Skill Sparks learning modules');
    }
    if (metrics.brainForgeScore < 50) {
      recommendations.add('Practice cognitive games in Brain Forge');
    }
    if (metrics.mindBalanceStreak < 7) {
      recommendations.add('Build a daily Mind Balance routine');
    }
    if (metrics.focusZoneDiscipline < 50) {
      recommendations.add('Use Focus Zone to improve concentration');
    }
    if (metrics.thoughtCirclesParticipation < 5) {
      recommendations.add('Engage more in Thought Circles discussions');
    }
    if (metrics.ideaLabImpactScore < 50) {
      recommendations.add('Submit innovative ideas in Idea Lab');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Continue maintaining your excellent growth trajectory!');
    }

    return recommendations;
  }

  String _generateMotivationalMessage(double rating) {
    if (rating >= 80) {
      return 'Outstanding progress! You\'re in the top tier of growth. Keep pushing forward!';
    } else if (rating >= 60) {
      return 'Great momentum! You\'re on a strong growth path. Keep up the excellent work!';
    } else if (rating >= 40) {
      return 'Steady progress! Every step forward counts. You\'re building a solid foundation.';
    } else {
      return 'Starting your journey! Every expert was once a beginner. Keep learning and growing!';
    }
  }
}
