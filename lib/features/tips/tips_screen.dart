// features/tips/tips_screen.dart
import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Center(child: Text("Wellness tips, mindfulness/breathing go here!")),
    );
  }
}
