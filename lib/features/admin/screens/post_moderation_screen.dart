import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

class PostModerationScreen extends StatefulWidget {
  const PostModerationScreen({super.key});

  @override
  State<PostModerationScreen> createState() => _PostModerationScreenState();
}

class _PostModerationScreenState extends State<PostModerationScreen> {
  final AdminService _service = AdminService();
  List<PostModerationItem> _posts = [];
  String _filterStatus = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _service.getModerationQueue(
        status: _filterStatus == 'all' ? null : _filterStatus,
      );
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approvePost(String postId) async {
    await _service.approvePost(postId);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post approved')),
      );
    }
  }

  Future<void> _rejectPost(String postId) async {
    // TODO: Show dialog for rejection reason
    await _service.rejectPost(postId, 'Does not align with culture values');
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post rejected')),
      );
    }
  }

  Future<void> _featurePost(String postId, bool isFeatured) async {
    await _service.featurePost(postId, isFeatured);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isFeatured ? 'Post featured' : 'Post unfeatured')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Post Moderation & Spotlight'),
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
              child: Column(
                children: [
                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _filterStatus == 'all',
                            onTap: () {
                              setState(() => _filterStatus = 'all');
                              _loadData();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Pending',
                            isSelected: _filterStatus == 'pending',
                            color: Colors.orange,
                            onTap: () {
                              setState(() => _filterStatus = 'pending');
                              _loadData();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Approved',
                            isSelected: _filterStatus == 'approved',
                            color: Colors.green,
                            onTap: () {
                              setState(() => _filterStatus == 'approved');
                              _loadData();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Flagged',
                            isSelected: _filterStatus == 'flagged',
                            color: Colors.red,
                            onTap: () {
                              setState(() => _filterStatus == 'flagged');
                              _loadData();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Posts List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _posts.isEmpty
                            ? Center(
                                child: Text(
                                  'No posts found',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _posts.length,
                                  itemBuilder: (context, index) {
                                    final post = _posts[index];
                                    return _PostModerationCard(
                                      post: post,
                                      onApprove: () =>
                                          _approvePost(post.postId),
                                      onReject: () => _rejectPost(post.postId),
                                      onFeature: (featured) =>
                                          _featurePost(post.postId, featured),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color ?? Colors.amber,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white.withOpacity(0.1),
    );
  }
}

class _PostModerationCard extends StatelessWidget {
  final PostModerationItem post;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final Function(bool) onFeature;

  const _PostModerationCard({
    required this.post,
    required this.onApprove,
    required this.onReject,
    required this.onFeature,
  });

  Color _getStatusColor() {
    switch (post.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'flagged':
        return Colors.red;
      case 'rejected':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${post.authorName}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (post.flaggedReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Flagged: ${post.flaggedReason}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.reactionCount} reactions',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (post.status == 'pending' || post.status == 'flagged') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (post.status == 'approved') ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => onFeature(true),
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Feature on Hero'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
