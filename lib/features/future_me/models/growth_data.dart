import 'package:flutter/material.dart';

enum PersonalityTrait {
  innovator,
  focusMaster,
  teamPlayer,
  problemSolver,
}

extension PersonalityTraitExtension on PersonalityTrait {
  String get displayName {
    switch (this) {
      case PersonalityTrait.innovator:
        return 'Innovator';
      case PersonalityTrait.focusMaster:
        return 'Focus Master';
      case PersonalityTrait.teamPlayer:
        return 'Team Player';
      case PersonalityTrait.problemSolver:
        return 'Problem Solver';
    }
  }

  IconData get icon {
    switch (this) {
      case PersonalityTrait.innovator:
        return Icons.lightbulb_rounded;
      case PersonalityTrait.focusMaster:
        return Icons.center_focus_strong_rounded;
      case PersonalityTrait.teamPlayer:
        return Icons.groups_rounded;
      case PersonalityTrait.problemSolver:
        return Icons.psychology_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PersonalityTrait.innovator:
        return Colors.orange;
      case PersonalityTrait.focusMaster:
        return Colors.blue;
      case PersonalityTrait.teamPlayer:
        return Colors.green;
      case PersonalityTrait.problemSolver:
        return Colors.purple;
    }
  }
}

class GrowthMetrics {
  final double skillSparksScore; // 0-100
  final double brainForgeScore; // 0-100
  final double mindBalanceStreak; // days
  final double focusZoneDiscipline; // 0-100
  final double thoughtCirclesParticipation; // 0-100
  final double ideaLabImpactScore; // 0-100
  final double meetingRoomContribution; // 0-100

  GrowthMetrics({
    required this.skillSparksScore,
    required this.brainForgeScore,
    required this.mindBalanceStreak,
    required this.focusZoneDiscipline,
    required this.thoughtCirclesParticipation,
    required this.ideaLabImpactScore,
    required this.meetingRoomContribution,
  });

  // Calculate weighted future growth rating (0-100)
  double get futureGrowthRating {
    final weights = {
      'skillSparks': 0.20,
      'brainForge': 0.15,
      'mindBalance': 0.15,
      'focusZone': 0.15,
      'thoughtCircles': 0.10,
      'ideaLab': 0.15,
      'meetingRoom': 0.10,
    };

    // Normalize streak to 0-100 (assuming max 30 days = 100)
    final normalizedStreak =
        (mindBalanceStreak / 30.0 * 100.0).clamp(0.0, 100.0);

    return (skillSparksScore * weights['skillSparks']! +
            brainForgeScore * weights['brainForge']! +
            normalizedStreak * weights['mindBalance']! +
            focusZoneDiscipline * weights['focusZone']! +
            thoughtCirclesParticipation * weights['thoughtCircles']! +
            ideaLabImpactScore * weights['ideaLab']! +
            meetingRoomContribution * weights['meetingRoom']!)
        .clamp(0.0, 100.0);
  }

  // Get dominant personality traits
  List<PersonalityTrait> get dominantTraits {
    final traitScores = {
      PersonalityTrait.innovator:
          (ideaLabImpactScore + thoughtCirclesParticipation) / 2,
      PersonalityTrait.focusMaster: (focusZoneDiscipline + brainForgeScore) / 2,
      PersonalityTrait.teamPlayer:
          (meetingRoomContribution + thoughtCirclesParticipation) / 2,
      PersonalityTrait.problemSolver: (brainForgeScore + skillSparksScore) / 2,
    };

    final sorted = traitScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(2).map((e) => e.key).toList();
  }
}

class SkillNode {
  final String id;
  final String name;
  final String category; // 'skill', 'cognitive', 'wellbeing', 'collaboration'
  final double level; // 0-100
  final List<String> connectedNodeIds;
  final bool isMastered;

  SkillNode({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    this.connectedNodeIds = const [],
    this.isMastered = false,
  });
}

class GrowthPrediction {
  final double currentRating;
  final double predictedRating3Months;
  final double predictedRating6Months;
  final double predictedRating12Months;
  final List<String> recommendedActions;
  final String motivationalMessage;

  GrowthPrediction({
    required this.currentRating,
    required this.predictedRating3Months,
    required this.predictedRating6Months,
    required this.predictedRating12Months,
    required this.recommendedActions,
    required this.motivationalMessage,
  });
}

class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final double targetScore;
  final double currentProgress;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetScore,
    required this.currentProgress,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  double get progressPercentage =>
      (currentProgress / targetScore * 100).clamp(0.0, 100.0);
}
