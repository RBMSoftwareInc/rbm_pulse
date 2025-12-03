import 'package:flutter/material.dart';

class PeerDiscussionScreen extends StatelessWidget {
  const PeerDiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Connect - AI Discussions'),
        backgroundColor: const Color(0xFF0F52BA),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _DiscussionCard(
                    topic: 'Work-Life Balance',
                    participants: 12,
                    lastActivity: '2 hours ago',
                    icon: Icons.balance,
                  ),
                  _DiscussionCard(
                    topic: 'Remote Collaboration',
                    participants: 8,
                    lastActivity: '5 hours ago',
                    icon: Icons.people,
                  ),
                  _DiscussionCard(
                    topic: 'Productivity Tips',
                    participants: 15,
                    lastActivity: '1 day ago',
                    icon: Icons.trending_up,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask AI or start a discussion...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () {
                      // TODO: Send message
                    },
                    backgroundColor: const Color(0xFF0F52BA),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  final String topic;
  final int participants;
  final String lastActivity;
  final IconData icon;

  const _DiscussionCard({
    required this.topic,
    required this.participants,
    required this.lastActivity,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0F52BA).withOpacity(0.2),
          child: Icon(icon, color: const Color(0xFF0F52BA)),
        ),
        title: Text(
          topic,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$participants participants • $lastActivity',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
        onTap: () {
          // TODO: Navigate to discussion thread
        },
      ),
    );
  }
}
