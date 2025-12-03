import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_models.dart';

/// Service for admin and leadership analytics
/// Uses Supabase for real-time data
class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get pulse heatmap data by team/department
  Future<List<PulseHeatmapData>> getPulseHeatmap({
    String? department,
    String? teamId,
  }) async {
    try {
      var query = _supabase.from('pulses').select('''
            profile_id,
            burnout_risk_score,
            engagement_score,
            profiles!inner(department, team_id)
          ''');

      final response = await query;
      
      // Filter by department/team in memory
      final filteredResponse = (response as List).where((pulse) {
        final profile = pulse['profiles'] as Map<String, dynamic>?;
        if (department != null && profile?['department'] != department) {
          return false;
        }
        if (teamId != null && profile?['team_id'] != teamId) {
          return false;
        }
        return true;
      }).toList();

      // Group by team/department
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var pulse in response as List) {
        final profile = pulse['profiles'] as Map<String, dynamic>;
        final dept = profile['department'] as String? ?? 'Unknown';
        final team = profile['team_id'] as String? ?? 'unknown';

        final key = '$dept-$team';
        grouped.putIfAbsent(key, () => []).add(pulse);
      }

      final List<PulseHeatmapData> heatmapData = [];
      for (var entry in grouped.entries) {
        final pulses = entry.value;
        if (pulses.isEmpty) continue;

        final avgBurnout = pulses
                .where((p) => p['burnout_risk_score'] != null)
                .map((p) => (p['burnout_risk_score'] as num).toDouble())
                .reduce((a, b) => a + b) /
            pulses.where((p) => p['burnout_risk_score'] != null).length;

        final avgEngagement = pulses
                .where((p) => p['engagement_score'] != null)
                .map((p) => (p['engagement_score'] as num).toDouble())
                .reduce((a, b) => a + b) /
            pulses.where((p) => p['engagement_score'] != null).length;

        final firstProfile = pulses.first['profiles'] as Map<String, dynamic>;
        final dept = firstProfile['department'] as String? ?? 'Unknown';

        heatmapData.add(PulseHeatmapData(
          teamId: entry.key,
          teamName: dept,
          avgBurnoutScore: avgBurnout,
          avgEngagementScore: avgEngagement,
          employeeCount: pulses.length,
          lastUpdated: DateTime.now(),
        ));
      }

      return heatmapData;
    } catch (e) {
      return [];
    }
  }

  /// Get culture health trends
  Future<List<CultureHealthTrend>> getCultureHealthTrends({
    int days = 30,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final response = await _supabase
          .from('culture_posts')
          .select('created_at, reactions, comment_count')
          .gte('created_at', startDate.toIso8601String())
          .eq('is_deleted', false)
          .order('created_at', ascending: true);

      // Group by date
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var post in response as List) {
        final dateStr = (post['created_at'] as String).substring(0, 10);
        grouped.putIfAbsent(dateStr, () => []).add(post);
      }

      final List<CultureHealthTrend> trends = [];
      for (var entry in grouped.entries) {
        final posts = entry.value;
        final date = DateTime.parse(entry.key);

        int totalReactions = 0;
        for (var post in posts) {
          final reactions = post['reactions'] as Map<String, dynamic>? ?? {};
          reactions.forEach((key, value) {
            totalReactions += (value as num).toInt();
          });
        }

        final healthScore = _calculateCultureHealthScore(
          posts.length,
          totalReactions,
          posts
              .map((p) => p['comment_count'] as int? ?? 0)
              .reduce((a, b) => a + b),
        );

        trends.add(CultureHealthTrend(
          date: date,
          healthScore: healthScore,
          totalPosts: posts.length,
          positiveReactions: totalReactions,
          engagementRate: totalReactions / (posts.length * 5.0).clamp(0.0, 1.0),
        ));
      }

      return trends;
    } catch (e) {
      return [];
    }
  }

  double _calculateCultureHealthScore(int posts, int reactions, int comments) {
    if (posts == 0) return 0.0;
    final engagement = (reactions + comments * 2) / (posts * 10.0);
    return (engagement * 100).clamp(0.0, 100.0);
  }

  /// Get innovation index
  Future<List<InnovationIndex>> getInnovationIndex({
    String? department,
  }) async {
    try {
      var query = _supabase.from('idea_submissions').select('''
            id,
            status,
            impact_score,
            profiles!inner(department, full_name)
          ''');

      final response = await query;
      
      // Filter by department in memory
      final filteredResponse = department != null
          ? (response as List).where((item) {
              final profile = item['profiles'] as Map<String, dynamic>?;
              return profile?['department'] == department;
            }).toList()
          : response;

      // Group by department
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var idea in response as List) {
        final profile = idea['profiles'] as Map<String, dynamic>;
        final dept = profile['department'] as String? ?? 'Unknown';
        grouped.putIfAbsent(dept, () => []).add(idea);
      }

      final List<InnovationIndex> indexes = [];
      for (var entry in grouped.entries) {
        final ideas = entry.value;
        final totalIdeas = ideas.length;
        final implementedIdeas =
            ideas.where((i) => i['status'] == 'implemented').length;

        final avgImpact = ideas
                .where((i) => i['impact_score'] != null)
                .map((i) => (i['impact_score'] as num).toDouble())
                .reduce((a, b) => a + b) /
            ideas.where((i) => i['impact_score'] != null).length;

        final topContributors = ideas
            .map((i) => i['profiles'] as Map<String, dynamic>)
            .map((p) => p['full_name'] as String? ?? 'Unknown')
            .toSet()
            .take(3)
            .toList();

        indexes.add(InnovationIndex(
          department: entry.key,
          totalIdeas: totalIdeas,
          implementedIdeas: implementedIdeas,
          impactScore: avgImpact,
          topContributors: topContributors,
        ));
      }

      return indexes;
    } catch (e) {
      return [];
    }
  }

  /// Get skill development data
  Future<List<SkillDevelopmentData>> getSkillDevelopmentData({
    String? skillArea,
  }) async {
    try {
      var query = _supabase
          .from('learning_activities')
          .select('module, score, completed_at');

      if (skillArea != null) {
        query = query.eq('module', skillArea);
      }

      final response = await query;

      // Group by module
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var activity in response as List) {
        final module = activity['module'] as String? ?? 'unknown';
        grouped.putIfAbsent(module, () => []).add(activity);
      }

      final List<SkillDevelopmentData> data = [];
      for (var entry in grouped.entries) {
        final activities = entry.value;
        final totalLearners =
            activities.map((a) => a['user_id']).toSet().length;
        final completions = activities.length;

        final avgProgress = activities
                .where((a) => a['score'] != null)
                .map((a) => (a['score'] as num).toDouble())
                .reduce((a, b) => a + b) /
            activities.where((a) => a['score'] != null).length;

        // Calculate growth rate (simplified)
        final growthRate = completions > 0 ? (completions / 10.0) : 0.0;

        data.add(SkillDevelopmentData(
          skillArea: _getSkillAreaName(entry.key),
          totalLearners: totalLearners,
          avgProgress: avgProgress,
          completions: completions,
          growthRate: growthRate,
        ));
      }

      return data;
    } catch (e) {
      return [];
    }
  }

  String _getSkillAreaName(String module) {
    switch (module) {
      case 'skill_sparks':
        return 'Technical Skills';
      case 'brain_forge':
        return 'Cognitive Skills';
      case 'thought_circles':
        return 'Communication';
      default:
        return module;
    }
  }

  /// Get meeting quality metrics
  Future<List<MeetingQualityMetrics>> getMeetingQualityMetrics({
    String? teamId,
  }) async {
    try {
      var query = _supabase.from('meetings').select('''
            id,
            duration_minutes,
            action_items!inner(status),
            profiles!inner(team_id, department)
          ''');

      final response = await query;
      
      // Filter by team in memory
      final filteredResponse = teamId != null
          ? (response as List).where((meeting) {
              final profile = meeting['profiles'] as Map<String, dynamic>?;
              return profile?['team_id'] == teamId;
            }).toList()
          : response;

      // Group by team
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var meeting in filteredResponse) {
        final profile = meeting['profiles'] as Map<String, dynamic>;
        final team = profile['team_id'] as String? ?? 'unknown';
        grouped.putIfAbsent(team, () => []).add(meeting);
      }

      final List<MeetingQualityMetrics> metrics = [];
      for (var entry in grouped.entries) {
        final meetings = entry.value;
        if (meetings.isEmpty) continue;

        final totalMeetings = meetings.length;
        final avgDuration = meetings
                .where((m) => m['duration_minutes'] != null)
                .map((m) => (m['duration_minutes'] as num).toDouble())
                .reduce((a, b) => a + b) /
            meetings.where((m) => m['duration_minutes'] != null).length;

        int completed = 0;
        int pending = 0;
        for (var meeting in meetings) {
          final actions = meeting['action_items'] as List? ?? [];
          for (var action in actions) {
            if (action['status'] == 'completed') {
              completed++;
            } else {
              pending++;
            }
          }
        }

        final productivityScore = _calculateProductivityScore(
          totalMeetings,
          avgDuration,
          completed,
          pending,
        );

        final firstProfile = meetings.first['profiles'] as Map<String, dynamic>;
        final teamName = firstProfile['department'] as String? ?? 'Unknown';

        metrics.add(MeetingQualityMetrics(
          teamId: entry.key,
          teamName: teamName,
          totalMeetings: totalMeetings,
          avgDuration: avgDuration,
          actionItemsCompleted: completed,
          actionItemsPending: pending,
          productivityScore: productivityScore,
        ));
      }

      return metrics;
    } catch (e) {
      return [];
    }
  }

  double _calculateProductivityScore(
    int meetings,
    double avgDuration,
    int completed,
    int pending,
  ) {
    if (meetings == 0) return 0.0;
    final completionRate =
        completed / (completed + pending).clamp(1, double.infinity);
    final durationScore = (60 - avgDuration) / 60.0; // Prefer shorter meetings
    return ((completionRate * 0.7 + durationScore * 0.3) * 100)
        .clamp(0.0, 100.0);
  }

  /// Get wellbeing metrics
  Future<List<WellbeingMetrics>> getWellbeingMetrics({
    String? department,
    String? riskLevel,
  }) async {
    try {
      var query = _supabase.from('pulses').select('''
            profile_id,
            burnout_risk_score,
            engagement_score,
            profiles!inner(department, full_name, team_id)
          ''').order('created_at', ascending: false);

      final response = await query;
      
      // Filter by department in memory if needed
      final filteredResponse = department != null
          ? (response as List).where((pulse) {
              final profile = pulse['profiles'] as Map<String, dynamic>?;
              return profile?['department'] == department;
            }).toList()
          : response;

      // Get latest pulse per user
      final Map<String, Map<String, dynamic>> latestPulses = {};
      for (var pulse in filteredResponse) {
        final profileId = pulse['profile_id'] as String;
        if (!latestPulses.containsKey(profileId)) {
          latestPulses[profileId] = pulse;
        }
      }

      // Get mind balance streaks
      final zenStreaks = await _supabase
          .from('zen_activities')
          .select('user_id, created_at')
          .order('created_at', ascending: false);

      final Map<String, int> streaks = {};
      for (var activity in zenStreaks as List) {
        final userId = activity['user_id'] as String;
        streaks[userId] = (streaks[userId] ?? 0) + 1;
      }

      final List<WellbeingMetrics> metrics = [];
      for (var entry in latestPulses.entries) {
        final pulse = entry.value;
        final profile = pulse['profiles'] as Map<String, dynamic>;
        final burnoutRisk =
            (pulse['burnout_risk_score'] as num?)?.toDouble() ?? 0.0;
        final engagement =
            (pulse['engagement_score'] as num?)?.toDouble() ?? 0.0;

        String riskLevelValue = 'low';
        if (burnoutRisk > 70) {
          riskLevelValue = 'high';
        } else if (burnoutRisk > 50) {
          riskLevelValue = 'medium';
        }

        if (riskLevel != null && riskLevelValue != riskLevel) continue;

        // Get focus consistency (simplified - count recent pulses)
        final userPulses = await _supabase
            .from('pulses')
            .select('id')
            .eq('profile_id', entry.key)
            .gte(
                'created_at',
                DateTime.now()
                    .subtract(const Duration(days: 30))
                    .toIso8601String());

        metrics.add(WellbeingMetrics(
          userId: entry.key,
          userName: profile['full_name'] as String? ?? 'Unknown',
          department: profile['department'] as String? ?? 'Unknown',
          burnoutRisk: burnoutRisk,
          engagementScore: engagement,
          mindBalanceStreak: streaks[entry.key] ?? 0,
          focusConsistency:
              ((userPulses as List).length / 30.0 * 100).clamp(0.0, 100.0),
          riskLevel: riskLevelValue,
        ));
      }

      return metrics;
    } catch (e) {
      return [];
    }
  }

  /// Get alerts
  Future<List<Alert>> getAlerts({
    String? type,
    String? severity,
  }) async {
    try {
      var query = _supabase.from('admin_alerts').select();

      if (type != null) {
        query = query.eq('alert_type', type);
      }
      if (severity != null) {
        query = query.eq('severity', severity);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => Alert(
                id: json['id'] as String,
                type: json['alert_type'] as String,
                title: json['title'] as String,
                description: json['description'] as String? ?? '',
                severity: json['severity'] as String,
                createdAt: DateTime.parse(json['created_at'] as String),
                teamId: json['team_id'] as String?,
              ))
          .toList();
    } catch (e) {
      // If alerts table doesn't exist, generate from data
      return await _generateAlertsFromData(type, severity);
    }
  }

  Future<List<Alert>> _generateAlertsFromData(
      String? type, String? severity) async {
    final alerts = <Alert>[];

    // Check for high burnout teams
    final heatmap = await getPulseHeatmap();
    for (var team in heatmap) {
      if (team.avgBurnoutScore > 60) {
        alerts.add(Alert(
          id: 'alert-${team.teamId}',
          type: 'burnout',
          title: 'High Burnout Risk Detected',
          description:
              '${team.teamName} shows ${team.avgBurnoutScore.toStringAsFixed(1)}% average burnout score',
          severity: team.avgBurnoutScore > 70 ? 'critical' : 'warning',
          createdAt: team.lastUpdated,
          teamId: team.teamId,
        ));
      }
    }

    // Filter by type and severity
    var filtered = alerts;
    if (type != null) {
      filtered = filtered.where((a) => a.type == type).toList();
    }
    if (severity != null) {
      filtered = filtered.where((a) => a.severity == severity).toList();
    }

    return filtered;
  }

  /// Get top contributors
  Future<List<TopContributor>> getTopContributors({
    String? category,
    int limit = 10,
  }) async {
    try {
      final contributors = <TopContributor>[];

      if (category == null || category == 'ideas') {
        // Top idea contributors
        final ideas = await _supabase
            .from('idea_submissions')
            .select(
                'user_id, impact_score, profiles!inner(full_name, department)')
            .order('impact_score', ascending: false)
            .limit(limit);

        for (var idea in ideas as List) {
          final profile = idea['profiles'] as Map<String, dynamic>;
          contributors.add(TopContributor(
            userId: idea['user_id'] as String,
            userName: profile['full_name'] as String? ?? 'Unknown',
            department: profile['department'] as String? ?? 'Unknown',
            category: 'ideas',
            score: (idea['impact_score'] as num?)?.toDouble() ?? 0.0,
            achievement: 'High impact idea',
          ));
        }
      }

      if (category == null || category == 'skills') {
        // Top learning contributors
        final learning = await _supabase
            .from('learning_activities')
            .select('user_id, score, profiles!inner(full_name, department)')
            .order('score', ascending: false)
            .limit(limit);

        for (var activity in learning as List) {
          final profile = activity['profiles'] as Map<String, dynamic>;
          contributors.add(TopContributor(
            userId: activity['user_id'] as String,
            userName: profile['full_name'] as String? ?? 'Unknown',
            department: profile['department'] as String? ?? 'Unknown',
            category: 'skills',
            score: (activity['score'] as num?)?.toDouble() ?? 0.0,
            achievement: 'Top learning score',
          ));
        }
      }

      contributors.sort((a, b) => b.score.compareTo(a.score));
      return contributors.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get AI narrative (AI-generated summary)
  Future<String> getAINarrative({
    String? teamId,
    String? department,
  }) async {
    try {
      // Generate narrative from recent data
      final heatmap = await getPulseHeatmap(department: department);
      final trends = await getCultureHealthTrends(days: 7);
      final innovation = await getInnovationIndex(department: department);

      final narratives = <String>[];

      if (heatmap.isNotEmpty) {
        final bestTeam = heatmap.reduce(
            (a, b) => a.avgEngagementScore > b.avgEngagementScore ? a : b);
        narratives.add(
            '${bestTeam.teamName} shows strong engagement at ${bestTeam.avgEngagementScore.toStringAsFixed(1)}%.');
      }

      if (trends.isNotEmpty) {
        final latest = trends.last;
        narratives.add(
            'Culture health is at ${latest.healthScore.toStringAsFixed(1)}% with ${latest.totalPosts} posts this week.');
      }

      if (innovation.isNotEmpty) {
        final totalIdeas =
            innovation.map((i) => i.totalIdeas).reduce((a, b) => a + b);
        final implemented =
            innovation.map((i) => i.implementedIdeas).reduce((a, b) => a + b);
        narratives.add(
            'Innovation momentum: $totalIdeas ideas submitted, $implemented implemented.');
      }

      return narratives.isEmpty
          ? 'No significant changes detected this week.'
          : narratives.join(' ');
    } catch (e) {
      return 'Unable to generate narrative at this time.';
    }
  }

  /// Get growth analytics
  Future<List<GrowthAnalytics>> getGrowthAnalytics({
    String? department,
    String? potentialLevel,
  }) async {
    try {
      var query = _supabase.from('growth_predictions').select('''
            user_id,
            current_rating,
            predicted_3_months,
            profiles!inner(department, full_name)
          ''');

      final response = await query;
      
      // Filter by department in memory
      final filteredResponse = department != null
          ? (response as List).where((item) {
              final profile = item['profiles'] as Map<String, dynamic>?;
              return profile?['department'] == department;
            }).toList()
          : response;

      final List<GrowthAnalytics> analytics = [];
      for (var item in filteredResponse) {
        final profile = item['profiles'] as Map<String, dynamic>;
        final currentRating = (item['current_rating'] as num).toDouble();
        final predicted =
            (item['predicted_3_months'] as num?)?.toDouble() ?? currentRating;

        String potential = 'medium';
        if (predicted > 80) {
          potential = 'high';
        } else if (predicted < 50) {
          potential = 'low';
        }

        if (potentialLevel != null && potential != potentialLevel) continue;

        analytics.add(GrowthAnalytics(
          userId: item['user_id'] as String,
          userName: profile['full_name'] as String? ?? 'Unknown',
          department: profile['department'] as String? ?? 'Unknown',
          currentGrowthRating: currentRating,
          predictedGrowth: predicted,
          skillGaps: [], // Would need separate query
          potentialLevel: potential,
          recommendedMentors: [], // Would need separate query
        ));
      }

      return analytics;
    } catch (e) {
      return [];
    }
  }

  /// Get post moderation queue
  Future<List<PostModerationItem>> getModerationQueue({
    String? status,
  }) async {
    try {
      var query = _supabase.from('culture_posts').select('''
            id,
            title,
            created_at,
            is_featured,
            profiles!created_by(full_name),
            reactions,
            comment_count
          ''').eq('is_deleted', false);

      if (status == 'pending') {
        query = query.eq('is_featured', false);
      } else if (status == 'approved') {
        query = query.eq('is_featured', true);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;
        final reactions = json['reactions'] as Map<String, dynamic>? ?? {};
        int reactionCount = 0;
        reactions.forEach((key, value) {
          reactionCount += (value as num).toInt();
        });

        return PostModerationItem(
          postId: json['id'] as String,
          title: json['title'] as String,
          authorName: profile?['full_name'] as String? ?? 'Unknown',
          createdAt: DateTime.parse(json['created_at'] as String),
          status:
              (json['is_featured'] as bool? ?? false) ? 'approved' : 'pending',
          reactionCount: reactionCount,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Approve post
  Future<void> approvePost(String postId) async {
    await _supabase
        .from('culture_posts')
        .update({'is_featured': true}).eq('id', postId);
  }

  /// Reject post
  Future<void> rejectPost(String postId, String reason) async {
    await _supabase
        .from('culture_posts')
        .update({'is_deleted': true}).eq('id', postId);
  }

  /// Feature post
  Future<void> featurePost(String postId, bool isFeatured) async {
    await _supabase
        .from('culture_posts')
        .update({'is_featured': isFeatured}).eq('id', postId);
  }
}
