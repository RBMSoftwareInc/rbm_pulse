import 'package:flutter/material.dart' hide Notification;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_models.dart';

/// Centralized Notification Service with rate limiting and context awareness
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Rate limiting: max notifications per user per hour
  static const int _maxNotificationsPerHour = 10;
  final Map<String, List<DateTime>> _notificationHistory = {};

  /// Check if notification should be sent based on rules
  Future<bool> shouldSendNotification(
    String userId,
    NotificationType type,
    NotificationPreference? preferences,
  ) async {
    // Check rate limiting
    if (!_checkRateLimit(userId)) {
      return false;
    }

    // Check preferences
    if (preferences != null) {
      if (preferences.doNotDisturbEnabled) {
        return false;
      }

      // Check quiet hours
      if (_isQuietHours(preferences)) {
        return false;
      }

      // Check category preferences
      switch (type) {
        case NotificationType.achievementUnlocked:
        case NotificationType.weeklyChallengeComplete:
          if (!preferences.achievementsEnabled) return false;
          break;
        case NotificationType.zenBreakPrompt:
          if (!preferences.focusZenNudgesEnabled) return false;
          break;
        case NotificationType.discussionReply:
        case NotificationType.recognitionReceived:
        case NotificationType.culturePostFeatured:
          if (!preferences.socialInteractionsEnabled) return false;
          break;
        case NotificationType.actionAssigned:
        case NotificationType.followUpDue:
        case NotificationType.meetingReminder:
          if (!preferences.actionRemindersEnabled) return false;
          break;
        case NotificationType.aiCoachNudge:
          if (!preferences.aiCoachEnabled) return false;
          break;
      }
    }

    // TODO: Check if user is in Focus Zone session
    // final isInFocusZone = await _checkFocusZoneSession(userId);
    // if (isInFocusZone && type != NotificationType.zenBreakPrompt) {
    //   return false;
    // }

    return true;
  }

  /// Check rate limiting
  bool _checkRateLimit(String userId) {
    final now = DateTime.now();
    final history = _notificationHistory[userId] ?? [];
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // Remove old entries
    final recentHistory = history.where((d) => d.isAfter(oneHourAgo)).toList();
    _notificationHistory[userId] = recentHistory;

    // Check limit
    if (recentHistory.length >= _maxNotificationsPerHour) {
      return false;
    }

    // Add current notification
    recentHistory.add(now);
    _notificationHistory[userId] = recentHistory;

    return true;
  }

  /// Check if current time is within quiet hours
  bool _isQuietHours(NotificationPreference preferences) {
    if (preferences.quietHoursStart == null ||
        preferences.quietHoursEnd == null) {
      return false;
    }

    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final startTime = _parseTime(preferences.quietHoursStart!);
    final endTime = _parseTime(preferences.quietHoursEnd!);

    if (startTime.hour < endTime.hour) {
      // Same day range (e.g., 9PM - 8AM doesn't make sense, but 9PM - 11PM does)
      return currentTime.hour >= startTime.hour &&
          currentTime.hour < endTime.hour;
    } else {
      // Overnight range (e.g., 9PM - 8AM)
      return currentTime.hour >= startTime.hour ||
          currentTime.hour < endTime.hour;
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Get user notification preferences
  Future<NotificationPreference?> getPreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('notification_prefs_$userId');
    if (jsonStr == null) return null;

    // In real implementation, fetch from Supabase
    // For now, return default preferences
    return NotificationPreference(userId: userId);
  }

  /// Save user notification preferences
  Future<void> savePreferences(NotificationPreference preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notification_prefs_${preferences.userId}',
      preferences.toJson().toString(),
    );

    // In real implementation, save to Supabase
  }

  /// Get notifications for user
  Future<List<Notification>> getNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, fetch from Supabase
    // Mock data for now
    return [
      Notification(
        id: 'n1',
        type: NotificationType.achievementUnlocked,
        priority: NotificationPriority.high,
        title: 'Achievement Unlocked!',
        body: 'You unlocked Innovator Badge! ✨',
        actionUrl: '/achievements',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Notification(
        id: 'n2',
        type: NotificationType.actionAssigned,
        priority: NotificationPriority.normal,
        title: 'New Action Item',
        body: 'New Action Item from meeting: Fix API bug',
        actionUrl: '/meetings/action-items',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Notification(
        id: 'n3',
        type: NotificationType.discussionReply,
        priority: NotificationPriority.normal,
        title: 'New Reply',
        body: 'Ravi replied to your idea 💬',
        actionUrl: '/thought-circles',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    // In real implementation, update in Supabase
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    // In real implementation, update in Supabase
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    final notifications = await getNotifications(userId, unreadOnly: true);
    return notifications.length;
  }

  /// Create notification (internal use)
  Future<void> createNotification(Notification notification) async {
    // In real implementation, save to Supabase and send push notification
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
