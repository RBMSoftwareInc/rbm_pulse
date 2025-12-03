import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/culture_post.dart';

/// Service for managing culture posts, reactions, and comments
/// Uses Supabase for data persistence
class CultureService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get hero post (daily top celebration)
  Future<CulturePost?> getHeroPost() async {
    try {
      final response = await _supabase
          .from('culture_posts')
          .select()
          .eq('is_hero', true)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return _postFromJson(response);
    } catch (e) {
      // If no hero post, return null
      return null;
    }
  }

  /// Get featured posts
  Future<List<CulturePost>> getFeaturedPosts({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('culture_posts')
          .select()
          .eq('is_featured', true)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(limit);

      final posts = await Future.wait(
        (response as List).map((json) => _postFromJson(json)),
      );
      return posts;
    } catch (e) {
      return [];
    }
  }

  /// Get all posts with pagination
  Future<List<CulturePost>> getPosts({
    int page = 1,
    int pageSize = 10,
    String? category,
  }) async {
    try {
      var query = _supabase
          .from('culture_posts')
          .select()
          .eq('is_deleted', false);

      if (category != null) {
        query = query.eq('category', category);
      }

      final orderedQuery = query.order('created_at', ascending: false);

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await orderedQuery.range(from, to);

      final posts = await Future.wait(
        (response as List).map((json) => _postFromJson(json)),
      );
      return posts;
    } catch (e) {
      return [];
    }
  }

  /// Get comments for a post
  Future<List<PostComment>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('post_comments')
          .select()
          .eq('post_id', postId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true);

      return (response as List).map((json) => _commentFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a reaction to a post
  Future<void> addReaction(
    String postId,
    String userId,
    ReactionType reactionType,
  ) async {
    try {
      // Check if user already reacted
      final existing = await _supabase
          .from('post_reactions')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .eq('reaction_type', reactionType.name)
          .maybeSingle();

      if (existing != null) {
        // Already reacted, do nothing
        return;
      }

      // Add reaction
      await _supabase.from('post_reactions').insert({
        'post_id': postId,
        'user_id': userId,
        'reaction_type': reactionType.name,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a reaction from a post
  Future<void> removeReaction(
    String postId,
    String userId,
    ReactionType reactionType,
  ) async {
    try {
      await _supabase
          .from('post_reactions')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .eq('reaction_type', reactionType.name);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a comment to a post
  Future<PostComment> addComment(
    String postId,
    String userId,
    String userName,
    String content,
  ) async {
    try {
      final response = await _supabase
          .from('post_comments')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'user_name': userName,
            'content': content,
          })
          .select()
          .single();

      return _commentFromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new post
  Future<CulturePost> createPost({
    required String title,
    String? description,
    required String category,
    String? mediaUrl,
    String? mediaType,
    required String createdBy,
    required String createdByName,
  }) async {
    try {
      final response = await _supabase
          .from('culture_posts')
          .insert({
            'title': title,
            'description': description,
            'category': category,
            'media_url': mediaUrl,
            'media_type': mediaType,
            'created_by': createdBy,
            'created_by_name': createdByName,
            'is_hero': false,
            'is_featured': false,
          })
          .select()
          .single();

      return _postFromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a post (admin only)
  Future<void> deletePost(String postId, String userId) async {
    try {
      // Check if user is admin (this should be handled by RLS policies)
      await _supabase
          .from('culture_posts')
          .update({'is_deleted': true}).eq('id', postId);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user has reacted to a post
  Future<bool> hasUserReacted(
    String postId,
    String userId,
    ReactionType reactionType,
  ) async {
    try {
      final response = await _supabase
          .from('post_reactions')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .eq('reaction_type', reactionType.name)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get reaction counts for a post
  Future<Map<String, int>> getReactionCounts(String postId) async {
    try {
      final response = await _supabase
          .from('post_reactions')
          .select('reaction_type')
          .eq('post_id', postId);

      final counts = <String, int>{};
      for (var item in response as List) {
        final type = item['reaction_type'] as String;
        counts[type] = (counts[type] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      return {};
    }
  }

  /// Get comment count for a post
  Future<int> getCommentCount(String postId) async {
    try {
      final response = await _supabase
          .from('post_comments')
          .select('id')
          .eq('post_id', postId)
          .eq('is_deleted', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Helper to convert JSON to CulturePost
  Future<CulturePost> _postFromJson(Map<String, dynamic> json) async {
    // Get reaction counts
    final reactionCounts = await getReactionCounts(json['id'] as String);

    // Get comment count
    final commentCount = await getCommentCount(json['id'] as String);

    return CulturePost(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
      createdBy: json['created_by'] as String,
      createdByName: json['created_by_name'] as String? ?? 'Unknown',
      createdByAvatar: json['created_by_avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isHero: json['is_hero'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      reactions: reactionCounts,
      commentCount: commentCount,
    );
  }

  /// Helper to convert JSON to PostComment
  PostComment _commentFromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Unknown',
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }
}
