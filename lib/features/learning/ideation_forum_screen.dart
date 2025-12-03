import 'package:flutter/material.dart';

class IdeationForumScreen extends StatelessWidget {
  const IdeationForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Think Tank - Ideation Forum'),
        backgroundColor: const Color(0xFFFFA500),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new idea
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share your idea!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _IdeaCard(
              title: 'Wellness Wednesday',
              description:
                  'Weekly team wellness sessions with mindfulness exercises.',
              author: 'Sarah M.',
              votes: 24,
              comments: 8,
            ),
            _IdeaCard(
              title: 'Flexible Work Hours',
              description:
                  'Allow employees to choose their work hours for better work-life balance.',
              author: 'John D.',
              votes: 45,
              comments: 12,
            ),
            _IdeaCard(
              title: 'Innovation Lab',
              description:
                  'Dedicated space for employees to experiment with new ideas.',
              author: 'Emma L.',
              votes: 32,
              comments: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final String title;
  final String description;
  final String author;
  final int votes;
  final int comments;

  const _IdeaCard({
    required this.title,
    required this.description,
    required this.author,
    required this.votes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.arrow_upward, color: Color(0xFFFFA500)),
                  onPressed: () {},
                ),
                Text(
                  '$votes',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'by $author',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.comment,
                  size: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '$comments',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
