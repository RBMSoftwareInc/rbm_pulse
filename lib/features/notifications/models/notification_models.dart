import 'package:flutter/material.dart';

enum NotificationType {
  achievementUnlocked,
  actionAssigned,
  followUpDue,
  discussionReply,
  recognitionReceived,
  aiCoachNudge,
  zenBreakPrompt,
  meetingReminder,
  culturePostFeatured,
  weeklyChallengeComplete,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.achievementUnlocked:
        return 'Achievement Unlocked';
      case NotificationType.actionAssigned:
        return 'Action Assigned';
      case NotificationType.followUpDue:
        return 'Follow-up Due';
      case NotificationType.discussionReply:
        return 'Discussion Reply';
      case NotificationType.recognitionReceived:
        return 'Recognition Received';
      case NotificationType.aiCoachNudge:
        return 'AI Coach Nudge';
      case NotificationType.zenBreakPrompt:
        return 'Zen Break Prompt';
      case NotificationType.meetingReminder:
        return 'Meeting Reminder';
      case NotificationType.culturePostFeatured:
        return 'Post Featured';
      case NotificationType.weeklyChallengeComplete:
        return 'Challenge Complete';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.achievementUnlocked:
        return Icons.emoji_events_rounded;
      case NotificationType.actionAssigned:
        return Icons.assignment_rounded;
      case NotificationType.followUpDue:
        return Icons.schedule_rounded;
      case NotificationType.discussionReply:
        return Icons.reply_rounded;
      case NotificationType.recognitionReceived:
        return Icons.favorite_rounded;
      case NotificationType.aiCoachNudge:
        return Icons.auto_awesome_rounded;
      case NotificationType.zenBreakPrompt:
        return Icons.self_improvement_rounded;
      case NotificationType.meetingReminder:
        return Icons.event_rounded;
      case NotificationType.culturePostFeatured:
        return Icons.star_rounded;
      case NotificationType.weeklyChallengeComplete:
        return Icons.check_circle_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.achievementUnlocked:
        return Colors.amber;
      case NotificationType.actionAssigned:
        return Colors.blue;
      case NotificationType.followUpDue:
        return Colors.orange;
      case NotificationType.discussionReply:
        return Colors.green;
      case NotificationType.recognitionReceived:
        return Colors.red;
      case NotificationType.aiCoachNudge:
        return Colors.purple;
      case NotificationType.zenBreakPrompt:
        return Colors.teal;
      case NotificationType.meetingReminder:
        return Colors.indigo;
      case NotificationType.culturePostFeatured:
        return Colors.pink;
      case NotificationType.weeklyChallengeComplete:
        return Colors.cyan;
    }
  }
}

enum NotificationPriority {
  high,
  normal,
  low,
}

class Notification {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final String? actionUrl; // Deep link to relevant screen
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final String? senderId;
  final String? senderName;

  Notification({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    this.actionUrl,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
    this.senderId,
    this.senderName,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderId: json['sender_id'] as String?,
      senderName: json['sender_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'title': title,
      'body': body,
      'action_url': actionUrl,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'sender_id': senderId,
      'sender_name': senderName,
    };
  }
}

class NotificationPreference {
  final String userId;
  final bool achievementsEnabled;
  final bool focusZenNudgesEnabled;
  final bool socialInteractionsEnabled;
  final bool actionRemindersEnabled;
  final bool aiCoachEnabled;
  final bool inAppEnabled;
  final bool emailEnabled;
  final String? quietHoursStart; // HH:mm format
  final String? quietHoursEnd; // HH:mm format
  final bool doNotDisturbEnabled;

  NotificationPreference({
    required this.userId,
    this.achievementsEnabled = true,
    this.focusZenNudgesEnabled = true,
    this.socialInteractionsEnabled = true,
    this.actionRemindersEnabled = true,
    this.aiCoachEnabled = true,
    this.inAppEnabled = true,
    this.emailEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.doNotDisturbEnabled = false,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      userId: json['user_id'] as String,
      achievementsEnabled: json['achievements_enabled'] as bool? ?? true,
      focusZenNudgesEnabled: json['focus_zen_nudges_enabled'] as bool? ?? true,
      socialInteractionsEnabled:
          json['social_interactions_enabled'] as bool? ?? true,
      actionRemindersEnabled: json['action_reminders_enabled'] as bool? ?? true,
      aiCoachEnabled: json['ai_coach_enabled'] as bool? ?? true,
      inAppEnabled: json['in_app_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? false,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
      doNotDisturbEnabled: json['do_not_disturb_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'achievements_enabled': achievementsEnabled,
      'focus_zen_nudges_enabled': focusZenNudgesEnabled,
      'social_interactions_enabled': socialInteractionsEnabled,
      'action_reminders_enabled': actionRemindersEnabled,
      'ai_coach_enabled': aiCoachEnabled,
      'in_app_enabled': inAppEnabled,
      'email_enabled': emailEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'do_not_disturb_enabled': doNotDisturbEnabled,
    };
  }
}
