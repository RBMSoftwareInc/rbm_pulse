import 'package:flutter/material.dart';

class CulturePost {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String? mediaUrl;
  final String? mediaType; // 'image' or 'video'
  final String createdBy;
  final String createdByName;
  final String? createdByAvatar;
  final DateTime createdAt;
  final bool isFeatured;
  final bool isHero;
  final Map<String, int> reactions; // reaction_type -> count
  final int commentCount;
  final bool isDeleted;

  CulturePost({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.mediaUrl,
    this.mediaType,
    required this.createdBy,
    required this.createdByName,
    this.createdByAvatar,
    required this.createdAt,
    this.isFeatured = false,
    this.isHero = false,
    Map<String, int>? reactions,
    this.commentCount = 0,
    this.isDeleted = false,
  }) : reactions = reactions ?? {};

  factory CulturePost.fromJson(Map<String, dynamic> json) {
    return CulturePost(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
      createdBy: json['created_by'] as String,
      createdByName: json['created_by_name'] as String,
      createdByAvatar: json['created_by_avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFeatured: json['is_featured'] as bool? ?? false,
      isHero: json['is_hero'] as bool? ?? false,
      reactions: json['reactions'] != null
          ? Map<String, int>.from(json['reactions'] as Map)
          : {},
      commentCount: json['comment_count'] as int? ?? 0,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_by_avatar': createdByAvatar,
      'created_at': createdAt.toIso8601String(),
      'is_featured': isFeatured,
      'is_hero': isHero,
      'reactions': reactions,
      'comment_count': commentCount,
      'is_deleted': isDeleted,
    };
  }
}

class PostReaction {
  final String id;
  final String postId;
  final String userId;
  final String
      reactionType; // helpful, innovative, inspiring, team_spirit, growth
  final DateTime createdAt;

  PostReaction({
    required this.id,
    required this.postId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      reactionType: json['reaction_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final bool isDeleted;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.isDeleted = false,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }
}

// Allowed categories
enum PostCategory {
  achievements,
  appreciation,
  innovationWins,
  teamSuccess,
  cultureValues,
}

extension PostCategoryExtension on PostCategory {
  String get displayName {
    switch (this) {
      case PostCategory.achievements:
        return 'Achievements';
      case PostCategory.appreciation:
        return 'Appreciation';
      case PostCategory.innovationWins:
        return 'Innovation Wins';
      case PostCategory.teamSuccess:
        return 'Team Success';
      case PostCategory.cultureValues:
        return 'Culture Values';
    }
  }

  IconData get icon {
    switch (this) {
      case PostCategory.achievements:
        return Icons.emoji_events_rounded;
      case PostCategory.appreciation:
        return Icons.favorite_rounded;
      case PostCategory.innovationWins:
        return Icons.lightbulb_rounded;
      case PostCategory.teamSuccess:
        return Icons.groups_rounded;
      case PostCategory.cultureValues:
        return Icons.psychology_rounded;
    }
  }
}

// Reaction types
enum ReactionType {
  helpful, // 🤝
  innovative, // 💡
  inspiring, // 🔥
  teamSpirit, // ⭐
  growth, // 🌱
}

extension ReactionTypeExtension on ReactionType {
  String get emoji {
    switch (this) {
      case ReactionType.helpful:
        return '🤝';
      case ReactionType.innovative:
        return '💡';
      case ReactionType.inspiring:
        return '🔥';
      case ReactionType.teamSpirit:
        return '⭐';
      case ReactionType.growth:
        return '🌱';
    }
  }

  String get displayName {
    switch (this) {
      case ReactionType.helpful:
        return 'Helpful';
      case ReactionType.innovative:
        return 'Innovative';
      case ReactionType.inspiring:
        return 'Inspiring';
      case ReactionType.teamSpirit:
        return 'Team Spirit';
      case ReactionType.growth:
        return 'Growth';
    }
  }

  Color get color {
    switch (this) {
      case ReactionType.helpful:
        return const Color(0xFF4A90E2);
      case ReactionType.innovative:
        return const Color(0xFFFFA500);
      case ReactionType.inspiring:
        return const Color(0xFFE74C3C);
      case ReactionType.teamSpirit:
        return const Color(0xFFFFD700);
      case ReactionType.growth:
        return const Color(0xFF2ECC71);
    }
  }
}
