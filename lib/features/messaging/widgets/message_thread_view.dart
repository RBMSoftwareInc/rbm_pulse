import 'package:flutter/material.dart';
import '../models/message_models.dart';
import '../services/messaging_service.dart';
import 'message_bubble.dart';
import 'message_input.dart';

class MessageThreadView extends StatefulWidget {
  final String threadId;
  final String userId;
  final String userName;

  const MessageThreadView({
    super.key,
    required this.threadId,
    required this.userId,
    required this.userName,
  });

  @override
  State<MessageThreadView> createState() => _MessageThreadViewState();
}

class _MessageThreadViewState extends State<MessageThreadView> {
  final MessagingService _service = MessagingService();
  final ScrollController _scrollController = ScrollController();
  MessageThread? _thread;
  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadThread() async {
    setState(() => _isLoading = true);
    try {
      final thread = await _service.getThread(widget.threadId);
      final messages = await _service.getMessages(widget.threadId);
      setState(() {
        _thread = thread;
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String content, List<String> mentions) async {
    if (content.trim().isEmpty) return;

    try {
      final message = await _service.sendMessage(
        threadId: widget.threadId,
        senderId: widget.userId,
        senderName: widget.userName,
        content: content,
        mentions: mentions,
      );
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  Future<void> _addReaction(String messageId, MessageReaction reaction) async {
    await _service.addReaction(messageId, widget.userId, reaction);
    _loadThread();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Thread Header
          if (_thread != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.forum_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_thread!.title != null)
                          Text(
                            _thread!.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        if (_thread!.description != null)
                          Text(
                            _thread!.description!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isOwnMessage =
                              message.senderId == widget.userId;
                          return MessageBubble(
                            message: message,
                            isOwnMessage: isOwnMessage,
                            onReaction: (reaction) =>
                                _addReaction(message.id, reaction),
                          );
                        },
                      ),
          ),

          // Message Input
          MessageInput(
            onSend: _sendMessage,
            onMention: () {
              // TODO: Show mention picker
            },
          ),
        ],
      ),
    );
  }
}
