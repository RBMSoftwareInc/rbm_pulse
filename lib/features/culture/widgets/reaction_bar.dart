import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/culture_post.dart';
import '../services/culture_service.dart';

class ReactionBar extends StatefulWidget {
  final Map<String, int> reactions;
  final String postId;

  const ReactionBar({
    super.key,
    required this.reactions,
    required this.postId,
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  final CultureService _service = CultureService();
  final Set<ReactionType> _userReactions = {};

  @override
  void initState() {
    super.initState();
    _loadUserReactions();
  }

  void _loadUserReactions() {
    // In real implementation, check which reactions user has made
    // For now, using mocked service
  }

  Future<void> _toggleReaction(ReactionType type) async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;

    setState(() {
      if (_userReactions.contains(type)) {
        _userReactions.remove(type);
        _service.removeReaction(widget.postId, userId, type);
      } else {
        _userReactions.add(type);
        _service.addReaction(widget.postId, userId, type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ReactionType.values.map((type) {
          final count = widget.reactions[type.name] ?? 0;
          final isActive = _userReactions.contains(type);

          return GestureDetector(
            onTap: () => _toggleReaction(type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isActive ? type.color.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? type.color : Colors.white.withOpacity(0.1),
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? type.color : Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
