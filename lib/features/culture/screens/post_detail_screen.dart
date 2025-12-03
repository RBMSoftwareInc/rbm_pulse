import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/culture_post.dart';
import '../services/culture_service.dart';
import '../widgets/category_badge.dart';
import '../widgets/reaction_bar.dart';
import 'comment_section.dart';

class PostDetailScreen extends StatefulWidget {
  final CulturePost post;
  final VoidCallback onPostUpdated;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CultureService _service = CultureService();
  List<PostComment> _comments = [];
  bool _isLoadingComments = true;
  bool _showDeleteOption = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkAdminAccess();
  }

  void _checkAdminAccess() {
    // In real implementation, check user role from profile
    // For now, show delete for testing
    setState(() {
      _showDeleteOption = true; // Should check actual role
    });
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments = await _service.getComments(widget.post.id);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Delete Post',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      await _service.deletePost(widget.post.id, userId);
      if (mounted) {
        Navigator.pop(context);
        widget.onPostUpdated();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Post Details'),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    CategoryBadge(category: widget.post.category),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      widget.post.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Author & Date
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            widget.post.createdByName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.createdByName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatDate(widget.post.createdAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showDeleteOption)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: _deletePost,
                            tooltip: 'Delete Post (Admin)',
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (widget.post.description != null)
                      Text(
                        widget.post.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),

                    // Media
                    if (widget.post.mediaUrl != null) ...[
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.1),
                          child: widget.post.mediaType == 'video'
                              ? const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Reaction Bar
                    ReactionBar(
                      reactions: widget.post.reactions,
                      postId: widget.post.id,
                    ),

                    const SizedBox(height: 32),

                    // Comments Section
                    CommentSection(
                      postId: widget.post.id,
                      comments: _comments,
                      isLoading: _isLoadingComments,
                      onCommentAdded: () => _loadComments(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
