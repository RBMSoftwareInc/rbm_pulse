import 'package:flutter/material.dart';

enum UserRole {
  employee,
  teamLead,
  hrManager,
  admin,
  superAdmin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.teamLead:
        return 'Team Lead';
      case UserRole.hrManager:
        return 'HR Manager';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.employee:
        return Colors.grey;
      case UserRole.teamLead:
        return Colors.blue;
      case UserRole.hrManager:
        return Colors.green;
      case UserRole.admin:
        return Colors.orange;
      case UserRole.superAdmin:
        return Colors.red;
    }
  }

  int get permissionLevel {
    switch (this) {
      case UserRole.employee:
        return 1;
      case UserRole.teamLead:
        return 2;
      case UserRole.hrManager:
        return 3;
      case UserRole.admin:
        return 4;
      case UserRole.superAdmin:
        return 5;
    }
  }
}

class PulseHeatmapData {
  final String teamId;
  final String teamName;
  final double avgBurnoutScore;
  final double avgEngagementScore;
  final int employeeCount;
  final DateTime lastUpdated;

  PulseHeatmapData({
    required this.teamId,
    required this.teamName,
    required this.avgBurnoutScore,
    required this.avgEngagementScore,
    required this.employeeCount,
    required this.lastUpdated,
  });
}

class CultureHealthTrend {
  final DateTime date;
  final double healthScore;
  final int totalPosts;
  final int positiveReactions;
  final double engagementRate;

  CultureHealthTrend({
    required this.date,
    required this.healthScore,
    required this.totalPosts,
    required this.positiveReactions,
    required this.engagementRate,
  });
}

class InnovationIndex {
  final String department;
  final int totalIdeas;
  final int implementedIdeas;
  final double impactScore;
  final List<String> topContributors;

  InnovationIndex({
    required this.department,
    required this.totalIdeas,
    required this.implementedIdeas,
    required this.impactScore,
    required this.topContributors,
  });
}

class SkillDevelopmentData {
  final String skillArea;
  final int totalLearners;
  final double avgProgress;
  final int completions;
  final double growthRate;

  SkillDevelopmentData({
    required this.skillArea,
    required this.totalLearners,
    required this.avgProgress,
    required this.completions,
    required this.growthRate,
  });
}

class MeetingQualityMetrics {
  final String teamId;
  final String teamName;
  final int totalMeetings;
  final double avgDuration;
  final int actionItemsCompleted;
  final int actionItemsPending;
  final double productivityScore;

  MeetingQualityMetrics({
    required this.teamId,
    required this.teamName,
    required this.totalMeetings,
    required this.avgDuration,
    required this.actionItemsCompleted,
    required this.actionItemsPending,
    required this.productivityScore,
  });
}

class WellbeingMetrics {
  final String userId;
  final String userName;
  final String department;
  final double burnoutRisk;
  final double engagementScore;
  final int mindBalanceStreak;
  final double focusConsistency;
  final String riskLevel; // 'low', 'moderate', 'high', 'critical'

  WellbeingMetrics({
    required this.userId,
    required this.userName,
    required this.department,
    required this.burnoutRisk,
    required this.engagementScore,
    required this.mindBalanceStreak,
    required this.focusConsistency,
    required this.riskLevel,
  });
}

class Alert {
  final String id;
  final String
      type; // 'stress', 'burnout', 'meeting_overload', 'low_engagement'
  final String title;
  final String description;
  final String severity; // 'info', 'warning', 'critical'
  final DateTime createdAt;
  final String? userId;
  final String? teamId;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.createdAt,
    this.userId,
    this.teamId,
  });
}

class TopContributor {
  final String userId;
  final String userName;
  final String department;
  final String category; // 'skills', 'ideas', 'wellness', 'meetings'
  final double score;
  final String achievement;

  TopContributor({
    required this.userId,
    required this.userName,
    required this.department,
    required this.category,
    required this.score,
    required this.achievement,
  });
}

class AISetting {
  final String id;
  final String key;
  final String category; // 'content', 'scoring', 'recommendations', 'filters'
  final dynamic value;
  final String description;
  final bool isEditable;

  AISetting({
    required this.id,
    required this.key,
    required this.category,
    required this.value,
    required this.description,
    this.isEditable = true,
  });
}

class PostModerationItem {
  final String postId;
  final String title;
  final String authorName;
  final DateTime createdAt;
  final String status; // 'pending', 'approved', 'flagged', 'rejected'
  final String? flaggedReason;
  final int reactionCount;

  PostModerationItem({
    required this.postId,
    required this.title,
    required this.authorName,
    required this.createdAt,
    required this.status,
    this.flaggedReason,
    this.reactionCount = 0,
  });
}

class GrowthAnalytics {
  final String userId;
  final String userName;
  final String department;
  final double currentGrowthRating;
  final double predictedGrowth;
  final List<String> skillGaps;
  final String potentialLevel; // 'high', 'medium', 'low'
  final List<String> recommendedMentors;

  GrowthAnalytics({
    required this.userId,
    required this.userName,
    required this.department,
    required this.currentGrowthRating,
    required this.predictedGrowth,
    required this.skillGaps,
    required this.potentialLevel,
    required this.recommendedMentors,
  });
}
