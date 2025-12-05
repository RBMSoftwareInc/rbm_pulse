// features/history/history_screen.dart
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final String profileId;
  const HistoryScreen({super.key, required this.profileId});
  @override
  Widget build(BuildContext context) {
    // Fetch user past pulses from Supabase
    return const Scaffold(
      body: Center(child: Text("Your check-in history goes here!")),
    );
  }
}
