import '../models/message_models.dart';

/// Messaging Service for internal conversations
class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  /// Check if user can send message in context
  bool canSendMessage(String userId, String contextType, String contextId) {
    // In real implementation, check role-based permissions
    // For now, allow all authenticated users
    return true;
  }

  /// Check if user can view thread
  bool canViewThread(String userId, MessageThread thread) {
    // Check if user is participant
    if (thread.participantIds.contains(userId)) {
      return true;
    }

    // In real implementation, check role-based permissions
    // Team leads can view team threads, HR/Admin can view all
    return false;
  }

  /// Get message thread
  Future<MessageThread?> getThread(String threadId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, fetch from Supabase
    // Mock data for now
    return MessageThread(
      id: threadId,
      contextType: 'meeting_action',
      contextId: 'action1',
      title: 'Fix API bug',
      participantIds: ['user1', 'user2'],
      participantNames: {
        'user1': 'John Doe',
        'user2': 'Jane Smith',
      },
      lastMessage: Message(
        id: 'm1',
        threadId: threadId,
        senderId: 'user2',
        senderName: 'Jane Smith',
        content: 'I\'ll take a look at this today.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      unreadCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  /// Get messages for thread
  Future<List<Message>> getMessages(String threadId, {int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, fetch from Supabase
    // Mock data for now
    return [
      Message(
        id: 'm1',
        threadId: threadId,
        senderId: 'user1',
        senderName: 'John Doe',
        content: 'Can someone help with this API bug?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: 'm2',
        threadId: threadId,
        senderId: 'user2',
        senderName: 'Jane Smith',
        content: 'I\'ll take a look at this today.',
        reactions: {
          'user1': MessageReaction.thumbsUp,
        },
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  }

  /// Send message
  Future<Message> sendMessage({
    required String threadId,
    required String senderId,
    required String senderName,
    required String content,
    List<String> mentions = const [],
    List<MessageAttachment> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, save to Supabase and send push notification
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      threadId: threadId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      mentions: mentions,
      attachments: attachments,
      createdAt: DateTime.now(),
    );

    return message;
  }

  /// Add reaction to message
  Future<void> addReaction(
    String messageId,
    String userId,
    MessageReaction reaction,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In real implementation, update in Supabase
  }

  /// Remove reaction from message
  Future<void> removeReaction(String messageId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In real implementation, update in Supabase
  }

  /// Get threads for user
  Future<List<MessageThread>> getThreads(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, fetch from Supabase
    return [];
  }

  /// Create thread
  Future<MessageThread> createThread({
    required String contextType,
    required String contextId,
    required List<String> participantIds,
    String? title,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, create in Supabase
    return MessageThread(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contextType: contextType,
      contextId: contextId,
      title: title,
      description: description,
      participantIds: participantIds,
      createdAt: DateTime.now(),
    );
  }
}
