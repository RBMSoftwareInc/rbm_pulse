import 'package:flutter/material.dart';

enum MeetingAccessLevel {
  private, // Only participants
  team, // Selected group
  orgLibrary, // Leader approval required
}

extension MeetingAccessLevelExtension on MeetingAccessLevel {
  String get displayName {
    switch (this) {
      case MeetingAccessLevel.private:
        return 'Private';
      case MeetingAccessLevel.team:
        return 'Team Access';
      case MeetingAccessLevel.orgLibrary:
        return 'Org Library';
    }
  }

  IconData get icon {
    switch (this) {
      case MeetingAccessLevel.private:
        return Icons.lock_rounded;
      case MeetingAccessLevel.team:
        return Icons.group_rounded;
      case MeetingAccessLevel.orgLibrary:
        return Icons.library_books_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MeetingAccessLevel.private:
        return Colors.red;
      case MeetingAccessLevel.team:
        return Colors.blue;
      case MeetingAccessLevel.orgLibrary:
        return Colors.green;
    }
  }
}

enum ActionItemStatus {
  pending,
  inProgress,
  done,
}

extension ActionItemStatusExtension on ActionItemStatus {
  String get displayName {
    switch (this) {
      case ActionItemStatus.pending:
        return 'Pending';
      case ActionItemStatus.inProgress:
        return 'In Progress';
      case ActionItemStatus.done:
        return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case ActionItemStatus.pending:
        return Colors.orange;
      case ActionItemStatus.inProgress:
        return Colors.blue;
      case ActionItemStatus.done:
        return Colors.green;
    }
  }
}

class Meeting {
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<String> participantIds;
  final List<String> participantNames;
  final String organizerId;
  final String organizerName;
  final MeetingAccessLevel accessLevel;
  final String? audioRecordId;
  final String? summaryId;
  final bool isRecorded;
  final Duration? duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meeting({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.participantIds,
    required this.participantNames,
    required this.organizerId,
    required this.organizerName,
    required this.accessLevel,
    this.audioRecordId,
    this.summaryId,
    this.isRecorded = false,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      participantIds: List<String>.from(json['participant_ids'] as List),
      participantNames: List<String>.from(json['participant_names'] as List),
      organizerId: json['organizer_id'] as String,
      organizerName: json['organizer_name'] as String,
      accessLevel: MeetingAccessLevel.values.firstWhere(
        (e) => e.name == json['access_level'] as String,
        orElse: () => MeetingAccessLevel.private,
      ),
      audioRecordId: json['audio_record_id'] as String?,
      summaryId: json['summary_id'] as String?,
      isRecorded: json['is_recorded'] as bool? ?? false,
      duration: json['duration_ms'] != null
          ? Duration(milliseconds: json['duration_ms'] as int)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'organizer_id': organizerId,
      'organizer_name': organizerName,
      'access_level': accessLevel.name,
      'audio_record_id': audioRecordId,
      'summary_id': summaryId,
      'is_recorded': isRecorded,
      'duration_ms': duration?.inMilliseconds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AudioRecord {
  final String id;
  final String meetingId;
  final String? fileUrl;
  final String? filePath;
  final int? fileSizeBytes;
  final Duration? duration;
  final DateTime recordedAt;
  final String? transcript; // Placeholder for future AI integration

  AudioRecord({
    required this.id,
    required this.meetingId,
    this.fileUrl,
    this.filePath,
    this.fileSizeBytes,
    this.duration,
    required this.recordedAt,
    this.transcript,
  });

  factory AudioRecord.fromJson(Map<String, dynamic> json) {
    return AudioRecord(
      id: json['id'] as String,
      meetingId: json['meeting_id'] as String,
      fileUrl: json['file_url'] as String?,
      filePath: json['file_path'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      duration: json['duration_ms'] != null
          ? Duration(milliseconds: json['duration_ms'] as int)
          : null,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      transcript: json['transcript'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'file_url': fileUrl,
      'file_path': filePath,
      'file_size_bytes': fileSizeBytes,
      'duration_ms': duration?.inMilliseconds,
      'recorded_at': recordedAt.toIso8601String(),
      'transcript': transcript,
    };
  }
}

class MeetingSummary {
  final String id;
  final String meetingId;
  final List<String> keyDecisions;
  final List<ActionItem> actionItems;
  final List<String> risks;
  final List<String> openQuestions;
  final String? notes;
  final DateTime generatedAt;
  final DateTime updatedAt;

  MeetingSummary({
    required this.id,
    required this.meetingId,
    required this.keyDecisions,
    required this.actionItems,
    required this.risks,
    required this.openQuestions,
    this.notes,
    required this.generatedAt,
    required this.updatedAt,
  });

  factory MeetingSummary.fromJson(Map<String, dynamic> json) {
    return MeetingSummary(
      id: json['id'] as String,
      meetingId: json['meeting_id'] as String,
      keyDecisions: List<String>.from(json['key_decisions'] as List),
      actionItems: (json['action_items'] as List)
          .map((item) => ActionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      risks: List<String>.from(json['risks'] as List),
      openQuestions: List<String>.from(json['open_questions'] as List),
      notes: json['notes'] as String?,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'key_decisions': keyDecisions,
      'action_items': actionItems.map((item) => item.toJson()).toList(),
      'risks': risks,
      'open_questions': openQuestions,
      'notes': notes,
      'generated_at': generatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ActionItem {
  final String id;
  final String meetingId;
  final String summaryId;
  final String description;
  final String assignedToId;
  final String assignedToName;
  final DateTime? dueDate;
  final ActionItemStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  ActionItem({
    required this.id,
    required this.meetingId,
    required this.summaryId,
    required this.description,
    required this.assignedToId,
    required this.assignedToName,
    this.dueDate,
    this.status = ActionItemStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'] as String,
      meetingId: json['meeting_id'] as String,
      summaryId: json['summary_id'] as String,
      description: json['description'] as String,
      assignedToId: json['assigned_to_id'] as String,
      assignedToName: json['assigned_to_name'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      status: ActionItemStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => ActionItemStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'summary_id': summaryId,
      'description': description,
      'assigned_to_id': assignedToId,
      'assigned_to_name': assignedToName,
      'due_date': dueDate?.toIso8601String(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
