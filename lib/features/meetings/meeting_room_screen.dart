import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/widgets/shimmer_card.dart';
import '../../core/animations/fade_in_animation.dart';
import '../../core/animations/scale_animation.dart';
import '../../core/utils/navigation_helper.dart';
import 'models/meeting.dart';
import 'services/meeting_service.dart';
import 'screens/record_meeting_screen.dart';
import 'screens/meeting_summary_screen.dart';
import 'screens/action_items_dashboard_screen.dart';
import 'screens/meeting_timeline_screen.dart';
import 'screens/create_meeting_screen.dart';

class MeetingRoomScreen extends StatefulWidget {
  const MeetingRoomScreen({super.key});

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  final MeetingService _service = MeetingService();
  List<Meeting> _recentMeetings = [];
  List<ActionItem> _pendingActions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final userId = session?.user.id;
      final meetings = await _service.getMeetings(
        userId: userId,
        limit: 5,
      );
      // Get action items from all meetings
      final allActions = <ActionItem>[];
      for (var meeting in meetings) {
        if (!mounted) return;
        final items = await _service.getActionItems(meeting.id);
        allActions.addAll(items.where((item) => item.status == ActionItemStatus.pending));
      }
      if (mounted) {
        setState(() {
          _recentMeetings = meetings;
          _pendingActions = allActions.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user info for notifications
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id;

    return Scaffold(
      appBar: AppHeader(
        title: 'Meeting Room',
        showBackButton: false,
        userId: userId,
      ),
      floatingActionButton: ScaleAnimation(
        delay: const Duration(milliseconds: 500),
        beginScale: 0.0,
        endScale: 1.0,
        curve: Curves.elasticOut,
        child: FloatingActionButton.extended(
          onPressed: () {
            NavigationHelper.pushSlide(
              context,
              CreateMeetingScreen(
                onMeetingCreated: () => _loadData(),
              ),
            );
          },
          backgroundColor: const Color(0xFFD72631),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'New Meeting',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
                  ? ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: 5,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerCard(height: 120),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
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
                                  colors: [
                                    Color(0xFF2E7D32),
                                    Color(0xFF4CAF50)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.meeting_room_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Meeting Room',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Clarity. Action. Progress.',
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

                            // Quick Actions
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionCard(
                                    title: 'Record Meeting',
                                    icon: Icons.mic_rounded,
                                    color: Colors.red,
                                    onTap: () {
                                      NavigationHelper.pushSlide(
                                        context,
                                        const RecordMeetingScreen(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickActionCard(
                                    title: 'Action Items',
                                    icon: Icons.checklist_rounded,
                                    color: Colors.blue,
                                    onTap: () {
                                      NavigationHelper.pushSlide(
                                        context,
                                        const ActionItemsDashboardScreen(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionCard(
                                    title: 'Timeline',
                                    icon: Icons.history_rounded,
                                    color: Colors.purple,
                                    onTap: () {
                                      NavigationHelper.pushSlide(
                                        context,
                                        const MeetingTimelineScreen(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickActionCard(
                                    title: 'Search',
                                    icon: Icons.search_rounded,
                                    color: Colors.orange,
                                    onTap: () {
                                      // TODO: Implement search screen
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Search functionality coming soon'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Pending Action Items
                            if (_pendingActions.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Pending Actions',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      NavigationHelper.pushSlide(
                                        context,
                                        const ActionItemsDashboardScreen(),
                                      );
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ..._pendingActions
                                  .map((action) => _ActionItemCard(
                                        action: action,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ActionItemsDashboardScreen(),
                                            ),
                                          );
                                        },
                                      )),
                              const SizedBox(height: 24),
                            ],

                            // Recent Meetings
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Meetings',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MeetingTimelineScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_recentMeetings.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No meetings yet. Create your first meeting!',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              )
                            else
                              ..._recentMeetings.map((meeting) => _MeetingCard(
                                    meeting: meeting,
                                    onTap: () async {
                                      final summary =
                                          await _service.getSummary(meeting.id);
                                      if (summary != null && mounted) {
                                        NavigationHelper.pushSlide(
                                          context,
                                          MeetingSummaryScreen(
                                            meeting: meeting,
                                            summary: summary,
                                          ),
                                        );
                                      }
                                    },
                                  )),
                          ],
                        ),
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItemCard extends StatelessWidget {
  final ActionItem action;
  final VoidCallback onTap;

  const _ActionItemCard({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.status.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action.status == ActionItemStatus.done
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: action.status.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          action.assignedToName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        if (action.dueDate != null) ...[
                          const Text(' • ',
                              style: TextStyle(color: Colors.white54)),
                          Text(
                            _formatDate(action.dueDate!),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: action.status.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  action.status.displayName,
                  style: TextStyle(
                    color: action.status.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 0) {
      return 'Overdue';
    } else {
      return '${difference.inDays}d left';
    }
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;

  const _MeetingCard({
    required this.meeting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.7),
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
                ],
              ),
              if (meeting.participantNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: meeting.participantNames.take(3).map((name) {
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
