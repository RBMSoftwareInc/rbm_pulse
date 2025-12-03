import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/meeting.dart';
import '../services/meeting_service.dart';
import 'meeting_summary_screen.dart';

class MeetingTimelineScreen extends StatefulWidget {
  const MeetingTimelineScreen({super.key});

  @override
  State<MeetingTimelineScreen> createState() => _MeetingTimelineScreenState();
}

class _MeetingTimelineScreenState extends State<MeetingTimelineScreen> {
  final MeetingService _service = MeetingService();
  List<Meeting> _meetings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    setState(() => _isLoading = true);
    try {
      final meetings = await _service.getMeetings();
      setState(() {
        _meetings = meetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Meeting Timeline'),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _meetings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_outlined,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No meetings found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMeetings,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _meetings.length,
                            itemBuilder: (context, index) {
                              final meeting = _meetings[index];
                              return _TimelineMeetingCard(
                                meeting: meeting,
                                onTap: () async {
                                  final summary =
                                      await _service.getSummary(meeting.id);
                                  if (summary != null && mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MeetingSummaryScreen(
                                          meeting: meeting,
                                          summary: summary,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
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

class _TimelineMeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;

  const _TimelineMeetingCard({
    required this.meeting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: meeting.accessLevel.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          meeting.accessLevel.icon,
                          size: 12,
                          color: meeting.accessLevel.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meeting.accessLevel.displayName,
                          style: TextStyle(
                            color: meeting.accessLevel.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (meeting.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  meeting.description!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(meeting.scheduledAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  if (meeting.duration != null) ...[
                    const Text(' • ', style: TextStyle(color: Colors.white54)),
                    Text(
                      _formatDuration(meeting.duration!),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (meeting.isRecorded) ...[
                    const Text(' • ', style: TextStyle(color: Colors.white54)),
                    const Icon(
                      Icons.mic_rounded,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Recorded',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              if (meeting.participantNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: meeting.participantNames.map((name) {
                    return Chip(
                      label: Text(
                        name,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      labelStyle: const TextStyle(color: Colors.white70),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}
