import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting.dart';

/// Service for managing meetings, recordings, summaries, and action items
/// Uses Supabase for data persistence
class MeetingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all meetings for a user
  Future<List<Meeting>> getMeetings({
    String? userId,
    MeetingAccessLevel? accessLevel,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('meetings')
          .select('''
            *,
            profiles!organizer_id(full_name),
            meeting_participants!inner(profiles!user_id(full_name))
          ''');

      if (userId != null) {
        query = query.or('organizer_id.eq.$userId,meeting_participants.user_id.eq.$userId');
      }

      if (accessLevel != null) {
        query = query.eq('access_level', accessLevel.name);
      }

      final response = await query
          .order('scheduled_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => _meetingFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a single meeting by ID
  Future<Meeting?> getMeeting(String meetingId) async {
    try {
      final response = await _supabase
          .from('meetings')
          .select('''
            *,
            profiles!organizer_id(full_name),
            meeting_participants(profiles!user_id(full_name))
          ''')
          .eq('id', meetingId)
          .single();

      return _meetingFromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a new meeting
  Future<Meeting> createMeeting({
    required String title,
    String? description,
    required DateTime scheduledAt,
    required String organizerId,
    required List<String> participantIds,
    required MeetingAccessLevel accessLevel,
  }) async {
    try {
      // Create meeting
      final meetingResponse = await _supabase
          .from('meetings')
          .insert({
            'title': title,
            'description': description,
            'scheduled_at': scheduledAt.toIso8601String(),
            'organizer_id': organizerId,
            'access_level': accessLevel.name,
          })
          .select()
          .single();

      final meetingId = meetingResponse['id'] as String;

      // Add participants
      for (var participantId in participantIds) {
        await _supabase.from('meeting_participants').insert({
          'meeting_id': meetingId,
          'user_id': participantId,
        });
      }

      return await getMeeting(meetingId) ?? _meetingFromJson(meetingResponse);
    } catch (e) {
      rethrow;
    }
  }

  /// Start meeting recording
  Future<String> startRecording(String meetingId) async {
    try {
      final response = await _supabase
          .from('audio_records')
          .insert({
            'meeting_id': meetingId,
            'status': 'recording',
            'started_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Update meeting
      await _supabase
          .from('meetings')
          .update({
            'audio_record_id': response['id'],
            'is_recorded': true,
            'started_at': DateTime.now().toIso8601String(),
          })
          .eq('id', meetingId);

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  /// Stop meeting recording
  Future<void> stopRecording(String recordId, String? fileUrl) async {
    try {
      await _supabase
          .from('audio_records')
          .update({
            'status': 'completed',
            'file_url': fileUrl,
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', recordId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get meeting summary
  Future<MeetingSummary?> getSummary(String meetingId) async {
    try {
      final response = await _supabase
          .from('meeting_summaries')
          .select('''
            *,
            action_items(*, profiles!assigned_to_id(full_name))
          ''')
          .eq('meeting_id', meetingId)
          .maybeSingle();

      if (response == null) return null;
      return _summaryFromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create or update meeting summary
  Future<MeetingSummary> saveSummary({
    required String meetingId,
    required List<String> keyDecisions,
    required List<String> risks,
    required List<String> openQuestions,
  }) async {
    try {
      // Check if summary exists
      final existing = await _supabase
          .from('meeting_summaries')
          .select('id')
          .eq('meeting_id', meetingId)
          .maybeSingle();

      Map<String, dynamic> summaryData = {
        'meeting_id': meetingId,
        'key_decisions': keyDecisions,
        'risks_issues': risks,
        'open_questions': openQuestions,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existing != null) {
        // Update
        await _supabase
            .from('meeting_summaries')
            .update(summaryData)
            .eq('id', existing['id']);
        summaryData['id'] = existing['id'];
      } else {
        // Create
        final response = await _supabase
            .from('meeting_summaries')
            .insert(summaryData)
            .select()
            .single();
        summaryData = response;
      }

      // Update meeting
      await _supabase
          .from('meetings')
          .update({'summary_id': summaryData['id']})
          .eq('id', meetingId);

      return await getSummary(meetingId) ?? _summaryFromJson(summaryData);
    } catch (e) {
      rethrow;
    }
  }

  /// Get action items for a meeting
  Future<List<ActionItem>> getActionItems(String meetingId) async {
    try {
      final response = await _supabase
          .from('action_items')
          .select('*, profiles!assigned_to_id(full_name)')
          .eq('meeting_id', meetingId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _actionItemFromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Create action item
  Future<ActionItem> createActionItem({
    required String meetingId,
    required String summaryId,
    required String description,
    required String assignedToId,
    required DateTime dueDate,
  }) async {
    try {
      final response = await _supabase
          .from('action_items')
          .insert({
            'meeting_id': meetingId,
            'summary_id': summaryId,
            'description': description,
            'assigned_to_id': assignedToId,
            'due_date': dueDate.toIso8601String(),
            'status': 'pending',
          })
          .select('*, profiles!assigned_to_id(full_name)')
          .single();

      return _actionItemFromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update action item status
  Future<void> updateActionItemStatus(
    String actionItemId,
    ActionItemStatus status,
  ) async {
    try {
      await _supabase
          .from('action_items')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', actionItemId);
    } catch (e) {
      rethrow;
    }
  }

  /// Search meetings
  Future<List<Meeting>> searchMeetings({
    String? title,
    String? decisionText,
    List<String>? participantIds,
    String? keyword,
  }) async {
    try {
      var query = _supabase.from('meetings').select('''
        *,
        profiles!organizer_id(full_name),
        meeting_participants(profiles!user_id(full_name)),
        meeting_summaries(key_decisions)
      ''');

      if (title != null) {
        query = query.ilike('title', '%$title%');
      }

      if (keyword != null) {
        query = query.or('title.ilike.%$keyword%,description.ilike.%$keyword%');
      }

      final response = await query.order('scheduled_at', ascending: false);

      var meetings = (response as List)
          .map((json) => _meetingFromJson(json))
          .toList();

      // Filter by decision text if provided
      if (decisionText != null) {
        meetings = meetings.where((m) {
          // This would need to check summary key_decisions
          return true; // Simplified
        }).toList();
      }

      // Filter by participants if provided
      if (participantIds != null && participantIds.isNotEmpty) {
        meetings = meetings.where((m) {
          return participantIds.any((id) => m.participantIds.contains(id));
        }).toList();
      }

      return meetings;
    } catch (e) {
      return [];
    }
  }

  /// Helper to convert JSON to Meeting
  Meeting _meetingFromJson(Map<String, dynamic> json) {
    final organizer = json['profiles'] as Map<String, dynamic>?;
    final organizerName = organizer?['full_name'] as String? ?? 'Unknown';

    final participants = json['meeting_participants'] as List? ?? [];
    final participantIds = <String>[];
    final participantNames = <String>[];

    for (var p in participants) {
      final profile = p['profiles'] as Map<String, dynamic>?;
      final userId = p['user_id'] as String;
      final userName = profile?['full_name'] as String? ?? userId;
      participantIds.add(userId);
      participantNames.add(userName);
    }

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
      participantIds: participantIds,
      participantNames: participantNames,
      organizerId: json['organizer_id'] as String,
      organizerName: organizerName,
      accessLevel: MeetingAccessLevel.values.firstWhere(
        (e) => e.name == json['access_level'],
        orElse: () => MeetingAccessLevel.team,
      ),
      audioRecordId: json['audio_record_id'] as String?,
      summaryId: json['summary_id'] as String?,
      isRecorded: json['is_recorded'] as bool? ?? false,
      duration: json['duration_minutes'] != null
          ? Duration(minutes: json['duration_minutes'] as int)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Helper to convert JSON to MeetingSummary
  MeetingSummary _summaryFromJson(Map<String, dynamic> json) {
    final actionItems = json['action_items'] as List? ?? [];
    final actionItemsList = actionItems
        .map((ai) => _actionItemFromJson(ai))
        .cast<ActionItem>()
        .toList();

    return MeetingSummary(
      id: json['id'] as String,
      meetingId: json['meeting_id'] as String,
      keyDecisions: (json['key_decisions'] as List?)?.cast<String>() ?? [],
      actionItems: actionItemsList,
      risks: (json['risks_issues'] as List?)?.cast<String>() ?? [],
      openQuestions: (json['open_questions'] as List?)?.cast<String>() ?? [],
      generatedAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Helper to convert JSON to ActionItem
  ActionItem _actionItemFromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final assignedToName = profile?['full_name'] as String? ??
        json['assigned_to_id'] as String;

    return ActionItem(
      id: json['id'] as String,
      meetingId: json['meeting_id'] as String,
      summaryId: json['summary_id'] as String? ?? '',
      description: json['description'] as String,
      assignedToId: json['assigned_to_id'] as String,
      assignedToName: assignedToName,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: ActionItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ActionItemStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
