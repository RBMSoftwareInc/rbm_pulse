import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/meeting.dart';
import '../services/meeting_service.dart';

class ActionItemsDashboardScreen extends StatefulWidget {
  const ActionItemsDashboardScreen({super.key});

  @override
  State<ActionItemsDashboardScreen> createState() =>
      _ActionItemsDashboardScreenState();
}

class _ActionItemsDashboardScreenState
    extends State<ActionItemsDashboardScreen> {
  final MeetingService _service = MeetingService();
  List<ActionItem> _allActions = [];
  List<ActionItem> _filteredActions = [];
  ActionItemStatus? _selectedStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActionItems();
  }

  Future<void> _loadActionItems() async {
    setState(() => _isLoading = true);
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final userId = session?.user.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      // Get all meetings for user, then get action items from each
      final meetings = await _service.getMeetings(userId: userId, limit: 100);
      final allItems = <ActionItem>[];
      for (var meeting in meetings) {
        final items = await _service.getActionItems(meeting.id);
        allItems.addAll(items);
      }
      setState(() {
        _allActions = allItems;
        _filteredActions = allItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterByStatus(ActionItemStatus? status) {
    setState(() {
      _selectedStatus = status;
      if (status == null) {
        _filteredActions = _allActions;
      } else {
        _filteredActions =
            _allActions.where((item) => item.status == status).toList();
      }
    });
  }

  Future<void> _toggleActionStatus(ActionItem item) async {
    final newStatus = item.status == ActionItemStatus.done
        ? ActionItemStatus.pending
        : ActionItemStatus.done;

    try {
      await _service.updateActionItemStatus(item.id, newStatus);
      await _loadActionItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Action Items'),
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
              child: Column(
                children: [
                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _selectedStatus == null,
                            onTap: () => _filterByStatus(null),
                          ),
                          const SizedBox(width: 8),
                          ...ActionItemStatus.values.map((status) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: status.displayName,
                                isSelected: _selectedStatus == status,
                                color: status.color,
                                onTap: () => _filterByStatus(status),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Action Items List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredActions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.checklist_outlined,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No action items found',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                itemCount: _filteredActions.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredActions[index];
                                  return _ActionItemCard(
                                    action: item,
                                    onToggle: () => _toggleActionStatus(item),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
      checkmarkColor: color ?? Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? Colors.blue) : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected ? (color ?? Colors.blue) : Colors.white.withOpacity(0.2),
      ),
    );
  }
}

class _ActionItemCard extends StatelessWidget {
  final ActionItem action;
  final VoidCallback onToggle;

  const _ActionItemCard({
    required this.action,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: action.status == ActionItemStatus.done
                        ? action.status.color.withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: action.status.color,
                      width: 2,
                    ),
                  ),
                  child: action.status == ActionItemStatus.done
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: action.status.color,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: action.status == ActionItemStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          action.assignedToName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        if (action.dueDate != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(action.dueDate!),
                            style: TextStyle(
                              color: _isOverdue(action.dueDate!)
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: _isOverdue(action.dueDate!)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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

  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now()) &&
        action.status != ActionItemStatus.done;
  }
}
