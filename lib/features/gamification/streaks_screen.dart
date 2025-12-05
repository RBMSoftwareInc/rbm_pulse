// features/gamification/streaks_screen.dart
import 'package:flutter/material.dart';

class StreaksScreen extends StatelessWidget {
  final String profileId;
  const StreaksScreen({super.key, required this.profileId});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Your streaks, badges, level-ups go here!")),
    );
  }
}
