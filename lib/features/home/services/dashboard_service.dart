import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching dashboard data
class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get user stats (check-ins, streaks, etc.)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get profile stats
      final profile = await _supabase
          .from('profiles')
          .select('current_streak, longest_streak, total_checkins')
          .eq('id', userId)
          .single();

      // Get recent pulse count (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentPulses = await _supabase
          .from('pulses')
          .select('id')
          .eq('profile_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String()) as List;

      // Get today's pulse
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayPulse = await _supabase
          .from('pulses')
          .select()
          .eq('profile_id', userId)
          .gte('created_at', todayStart.toIso8601String())
          .maybeSingle();

      return {
        'currentStreak': profile['current_streak'] ?? 0,
        'longestStreak': profile['longest_streak'] ?? 0,
        'totalCheckins': profile['total_checkins'] ?? 0,
        'recentCheckins': recentPulses.length,
        'hasTodayCheckin': todayPulse != null,
      };
    } catch (e) {
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'totalCheckins': 0,
        'recentCheckins': 0,
        'hasTodayCheckin': false,
      };
    }
  }

  /// Get growth score and level
  Future<Map<String, dynamic>> getGrowthScore(String userId) async {
    try {
      // Get latest growth snapshot
      final snapshot = await _supabase
          .from('growth_snapshots')
          .select()
          .eq('user_id', userId)
          .order('snapshot_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (snapshot != null) {
        final rating =
            (snapshot['future_growth_rating'] as num?)?.toDouble() ?? 0.0;
        final score = (rating * 10).round(); // Convert 0-100 to 0-1000 scale
        final level = _calculateLevel(score);
        final xpToNext = _calculateXPToNext(score, level);

        return {
          'score': score,
          'level': level,
          'xpToNext': xpToNext,
          'rating': rating,
        };
      }

      // If no snapshot, calculate from various sources
      final score = await _calculateGrowthScoreFromActivities(userId);
      final level = _calculateLevel(score);
      final xpToNext = _calculateXPToNext(score, level);

      return {
        'score': score,
        'level': level,
        'xpToNext': xpToNext,
        'rating': score / 10.0,
      };
    } catch (e) {
      return {
        'score': 0,
        'level': 1,
        'xpToNext': 100,
        'rating': 0.0,
      };
    }
  }

  /// Calculate growth score from various activities
  Future<int> _calculateGrowthScoreFromActivities(String userId) async {
    try {
      int totalScore = 0;

      // Skill Sparks score (from learning activities)
      final skillSparks = await _supabase
          .from('learning_activities')
          .select('score')
          .eq('user_id', userId)
          .eq('module', 'skill_sparks')
          .order('created_at', ascending: false)
          .limit(10);

      if (skillSparks.isNotEmpty) {
        final avgScore = skillSparks
                .map((e) => (e['score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            skillSparks.length;
        totalScore += (avgScore * 2).round();
      }

      // Brain Forge score
      final brainForge = await _supabase
          .from('learning_activities')
          .select('score')
          .eq('user_id', userId)
          .eq('module', 'brain_forge')
          .order('created_at', ascending: false)
          .limit(10);

      if (brainForge.isNotEmpty) {
        final avgScore = brainForge
                .map((e) => (e['score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            brainForge.length;
        totalScore += (avgScore * 2).round();
      }

      // Mind Balance streak
      final mindBalance = await _supabase
          .from('zen_activities')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mindBalance.isNotEmpty) {
        totalScore += (mindBalance.length * 5);
      }

      // Pulse check-ins (engagement)
      final pulses = await _supabase
          .from('pulses')
          .select('engagement_score')
          .eq('profile_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      if (pulses.isNotEmpty) {
        final avgEngagement = pulses
                .map((e) => (e['engagement_score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            pulses.length;
        totalScore += (avgEngagement * 3).round();
      }

      return totalScore.clamp(0, 10000);
    } catch (e) {
      // If tables don't exist, return base score from pulses
      try {
        final pulses = await _supabase
            .from('pulses')
            .select('id')
            .eq('profile_id', userId) as List;

        return pulses.length * 10;
      } catch (_) {
        return 0;
      }
    }
  }

  int _calculateLevel(int score) {
    // Level 1: 0-100, Level 2: 101-300, Level 3: 301-600, etc.
    if (score < 100) return 1;
    if (score < 300) return 2;
    if (score < 600) return 3;
    if (score < 1000) return 4;
    if (score < 1500) return 5;
    if (score < 2200) return 6;
    if (score < 3000) return 7;
    if (score < 4000) return 8;
    if (score < 5000) return 9;
    return 10 + ((score - 5000) / 1000).floor();
  }

  int _calculateXPToNext(int score, int level) {
    final levelThresholds = [
      0,
      100,
      300,
      600,
      1000,
      1500,
      2200,
      3000,
      4000,
      5000,
    ];

    if (level >= levelThresholds.length) {
      final nextLevel = level + 1;
      final currentThreshold = 5000 + (level - 9) * 1000;
      final nextThreshold = 5000 + (nextLevel - 9) * 1000;
      return nextThreshold - score;
    }

    if (level < levelThresholds.length) {
      final nextThreshold = levelThresholds[level];
      return nextThreshold - score;
    }

    return 100;
  }

  /// Get recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity(String userId) async {
    try {
      final activities = <Map<String, dynamic>>[];

      // Recent pulses
      final recentPulses = await _supabase
          .from('pulses')
          .select('created_at, engagement_score')
          .eq('profile_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      for (var pulse in recentPulses) {
        activities.add({
          'type': 'pulse',
          'title': 'Daily Check-in',
          'date': DateTime.parse(pulse['created_at'] as String),
          'score': (pulse['engagement_score'] as num?)?.toDouble(),
        });
      }

      // Recent learning activities
      try {
        final learning = await _supabase
            .from('learning_activities')
            .select('module, created_at, score')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(5);

        for (var activity in learning) {
          activities.add({
            'type': 'learning',
            'title': _getModuleName(activity['module'] as String? ?? ''),
            'date': DateTime.parse(activity['created_at'] as String),
            'score': (activity['score'] as num?)?.toDouble(),
          });
        }
      } catch (_) {
        // Table might not exist
      }

      // Sort by date
      activities.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      return activities.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  String _getModuleName(String module) {
    switch (module) {
      case 'skill_sparks':
        return 'Skill Sparks';
      case 'brain_forge':
        return 'Brain Forge';
      case 'thought_circles':
        return 'Thought Circles';
      case 'idea_lab':
        return 'Idea Lab';
      case 'focus_zone':
        return 'Focus Zone';
      default:
        return 'Learning Activity';
    }
  }
}
