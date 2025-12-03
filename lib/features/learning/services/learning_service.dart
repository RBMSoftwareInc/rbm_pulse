import 'package:supabase_flutter/supabase_flutter.dart';

class LearningContent {
  final String id;
  final String title;
  final String category;
  final String type; // 'article', 'video', 'audio', 'interactive'
  final String? description;
  final String? content;
  final String? mediaUrl;
  final int? durationMinutes;
  final DateTime createdAt;
  final int? score;

  LearningContent({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    this.description,
    this.content,
    this.mediaUrl,
    this.durationMinutes,
    required this.createdAt,
    this.score,
  });
}

/// Service for managing learning content
/// Uses Supabase for data persistence
class LearningService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get learning content for a module
  Future<List<LearningContent>> getLearningContent({
    required String module, // 'skill_sparks', 'brain_forge', etc.
    String? category,
    int limit = 20,
  }) async {
    try {
      var query = _supabase
          .from('learning_content')
          .select()
          .eq('module', module)
          .eq('is_active', true);

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => _contentFromJson(json)).toList();
    } catch (e) {
      // If table doesn't exist, return empty list
      return [];
    }
  }

  /// Get user's learning activities
  Future<List<LearningContent>> getUserLearningActivities({
    required String userId,
    String? module,
  }) async {
    try {
      var query = _supabase
          .from('learning_activities')
          .select('''
            *,
            learning_content!content_id(*)
          ''')
          .eq('user_id', userId);

      if (module != null) {
        query = query.eq('module', module);
      }

      final orderedQuery = query.order('created_at', ascending: false).limit(50);

      final response = await orderedQuery;

      return (response as List).map((json) {
        final content = json['learning_content'] as Map<String, dynamic>?;
        if (content != null) {
          return _contentFromJson(content);
        }
        // Fallback if content not joined
        return _activityToContent(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Record learning activity completion
  Future<void> recordLearningActivity({
    required String userId,
    required String contentId,
    required String module,
    int? score,
    int? durationMinutes,
  }) async {
    try {
      await _supabase.from('learning_activities').insert({
        'user_id': userId,
        'content_id': contentId,
        'module': module,
        'score': score,
        'duration_minutes': durationMinutes,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore errors if table doesn't exist
    }
  }

  LearningContent _contentFromJson(Map<String, dynamic> json) {
    return LearningContent(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'General',
      type: json['type'] as String? ?? 'article',
      description: json['description'] as String?,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      score: json['score'] as int?,
    );
  }

  LearningContent _activityToContent(Map<String, dynamic> json) {
    return LearningContent(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Learning Activity',
      category: json['category'] as String? ?? 'General',
      type: json['type'] as String? ?? 'article',
      durationMinutes: json['duration_minutes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      score: json['score'] as int?,
    );
  }
}
