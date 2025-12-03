import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import 'screens/game_screen.dart';

class BrainForgeScreen extends StatelessWidget {
  const BrainForgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Brain Forge'),
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
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F52BA), Color(0xFF00D4FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.extension_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Brain Forge',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sharpen your mind through play',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Game Selection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _GameCard(
                      title: 'Pattern Recognition',
                      description: 'Identify patterns and sequences',
                      difficulty: 'Medium',
                      icon: Icons.grid_view_rounded,
                    ),
                    const _GameCard(
                      title: 'Memory Challenge',
                      description: 'Test your recall abilities',
                      difficulty: 'Hard',
                      icon: Icons.memory_rounded,
                    ),
                    const _GameCard(
                      title: 'Logic Puzzles',
                      description: 'Solve complex reasoning problems',
                      difficulty: 'Hard',
                      icon: Icons.psychology_rounded,
                    ),
                    const _GameCard(
                      title: 'Speed Challenge',
                      description: 'Quick thinking under pressure',
                      difficulty: 'Easy',
                      icon: Icons.speed_rounded,
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
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final String difficulty;
  final IconData icon;

  const _GameCard({
    required this.title,
    required this.description,
    required this.difficulty,
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
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        trailing: Chip(
          label: Text(difficulty),
          backgroundColor: const Color(0xFF0F52BA).withOpacity(0.2),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(
                gameTitle: title,
                difficulty: difficulty,
              ),
            ),
          );
        },
      ),
    );
  }
}
