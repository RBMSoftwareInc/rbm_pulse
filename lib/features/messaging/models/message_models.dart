import 'package:flutter/material.dart';

enum MessageReaction {
  thumbsUp,
  lightbulb,
  celebrate,
  heart,
}

extension MessageReactionExtension on MessageReaction {
  String get emoji {
    switch (this) {
      case MessageReaction.thumbsUp:
        return '👍';
      case MessageReaction.lightbulb:
        return '💡';
      case MessageReaction.celebrate:
        return '🙌';
      case MessageReaction.heart:
        return '❤️';
    }
  }

  IconData get icon {
    switch (this) {
      case MessageReaction.thumbsUp:
        return Icons.thumb_up_rounded;
      case MessageReaction.lightbulb:
        return Icons.lightbulb_rounded;
      case MessageReaction.celebrate:
        return Icons.celebration_rounded;
      case MessageReaction.heart:
        return Icons.favorite_rounded;
    }
  }
}

class Message {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final List<String> mentions; // User IDs mentioned
  final List<MessageAttachment> attachments;
  final Map<String, MessageReaction> reactions; // userId -> reaction
  final bool isEdited;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    this.mentions = const [],
    this.attachments = const [],
    this.reactions = const {},
    this.isEdited = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      senderAvatar: json['sender_avatar'] as String?,
      content: json['content'] as String,
      mentions: (json['mentions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map(
                  (e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              MessageReaction.values.firstWhere(
                (e) => e.toString().split('.').last == v,
              ),
            ),
          ) ??
          {},
      isEdited: json['is_edited'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thread_id': threadId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'mentions': mentions,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'reactions': reactions.map(
        (k, v) => MapEntry(k, v.toString().split('.').last),
      ),
      'is_edited': isEdited,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class MessageAttachment {
  final String id;
  final String type; // 'image', 'screenshot', 'file'
  final String url;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;

  MessageAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'file_name': fileName,
      'file_size': fileSize,
    };
  }
}

class MessageThread {
  final String id;
  final String contextType; // 'meeting_action', 'idea_lab', 'thought_circle'
  final String contextId; // ID of the parent entity
  final String? title;
  final String? description;
  final List<String> participantIds;
  final Map<String, String> participantNames; // userId -> name
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageThread({
    required this.id,
    required this.contextType,
    required this.contextId,
    this.title,
    this.description,
    required this.participantIds,
    this.participantNames = const {},
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      id: json['id'] as String,
      contextType: json['context_type'] as String,
      contextId: json['context_id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      participantIds: (json['participant_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      participantNames: (json['participant_names'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'context_type': contextType,
      'context_id': contextId,
      'title': title,
      'description': description,
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
