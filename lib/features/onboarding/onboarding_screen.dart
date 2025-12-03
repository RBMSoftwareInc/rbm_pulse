import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const OnboardingScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to RBM-Pulse',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'This app gives our organisation a daily “heartbeat” of how people feel at work using a scientific mood model (valence + energy). '
                'Your responses are anonymous and used only in aggregate to guide wellbeing decisions, not for performance reviews.',
              ),
              const SizedBox(height: 16),
              Text(
                'You will answer a 20–25 second daily check-in using colours and two sliders. '
                'Occasionally you may see one extra question from short, validated wellbeing scales.',
              ),
              const SizedBox(height: 16),
              Text(
                'Participation is voluntary. Data is never used to single out individuals; it is about patterns over time so leaders can improve workload, support, and work design.',
              ),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                child: const Text('I understand, continue'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
