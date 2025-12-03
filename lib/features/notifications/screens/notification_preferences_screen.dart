import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/notification_models.dart';
import '../services/notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  final String userId;

  const NotificationPreferencesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final NotificationService _service = NotificationService();
  NotificationPreference? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _service.getPreferences(widget.userId);
      setState(() {
        _preferences = prefs ?? NotificationPreference(userId: widget.userId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _preferences = NotificationPreference(userId: widget.userId);
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (_preferences == null) return;

    setState(() => _isSaving = true);
    try {
      await _service.savePreferences(_preferences!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Notification Preferences'),
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Customize your notification preferences to stay informed without being overwhelmed.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Notification Categories
                          const Text(
                            'Notification Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _PreferenceSwitch(
                            title: 'Achievements',
                            description: 'Badge unlocks, challenge completions',
                            icon: Icons.emoji_events_rounded,
                            value: _preferences!.achievementsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled: value,
                                  focusZenNudgesEnabled:
                                      _preferences!.focusZenNudgesEnabled,
                                  socialInteractionsEnabled:
                                      _preferences!.socialInteractionsEnabled,
                                  actionRemindersEnabled:
                                      _preferences!.actionRemindersEnabled,
                                  aiCoachEnabled: _preferences!.aiCoachEnabled,
                                  inAppEnabled: _preferences!.inAppEnabled,
                                  emailEnabled: _preferences!.emailEnabled,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled:
                                      _preferences!.doNotDisturbEnabled,
                                );
                              });
                            },
                          ),
                          _PreferenceSwitch(
                            title: 'Focus & Zen Nudges',
                            description: 'Break reminders, mindfulness prompts',
                            icon: Icons.self_improvement_rounded,
                            value: _preferences!.focusZenNudgesEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled:
                                      _preferences!.achievementsEnabled,
                                  focusZenNudgesEnabled: value,
                                  socialInteractionsEnabled:
                                      _preferences!.socialInteractionsEnabled,
                                  actionRemindersEnabled:
                                      _preferences!.actionRemindersEnabled,
                                  aiCoachEnabled: _preferences!.aiCoachEnabled,
                                  inAppEnabled: _preferences!.inAppEnabled,
                                  emailEnabled: _preferences!.emailEnabled,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled:
                                      _preferences!.doNotDisturbEnabled,
                                );
                              });
                            },
                          ),
                          _PreferenceSwitch(
                            title: 'Social Interactions',
                            description: 'Replies, recognition, mentions',
                            icon: Icons.people_rounded,
                            value: _preferences!.socialInteractionsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled:
                                      _preferences!.achievementsEnabled,
                                  focusZenNudgesEnabled:
                                      _preferences!.focusZenNudgesEnabled,
                                  socialInteractionsEnabled: value,
                                  actionRemindersEnabled:
                                      _preferences!.actionRemindersEnabled,
                                  aiCoachEnabled: _preferences!.aiCoachEnabled,
                                  inAppEnabled: _preferences!.inAppEnabled,
                                  emailEnabled: _preferences!.emailEnabled,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled:
                                      _preferences!.doNotDisturbEnabled,
                                );
                              });
                            },
                          ),
                          _PreferenceSwitch(
                            title: 'Action Reminders',
                            description: 'Meeting actions, follow-ups',
                            icon: Icons.assignment_rounded,
                            value: _preferences!.actionRemindersEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled:
                                      _preferences!.achievementsEnabled,
                                  focusZenNudgesEnabled:
                                      _preferences!.focusZenNudgesEnabled,
                                  socialInteractionsEnabled:
                                      _preferences!.socialInteractionsEnabled,
                                  actionRemindersEnabled: value,
                                  aiCoachEnabled: _preferences!.aiCoachEnabled,
                                  inAppEnabled: _preferences!.inAppEnabled,
                                  emailEnabled: _preferences!.emailEnabled,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled:
                                      _preferences!.doNotDisturbEnabled,
                                );
                              });
                            },
                          ),
                          _PreferenceSwitch(
                            title: 'AI Coach Suggestions',
                            description: 'Personalized growth recommendations',
                            icon: Icons.auto_awesome_rounded,
                            value: _preferences!.aiCoachEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled:
                                      _preferences!.achievementsEnabled,
                                  focusZenNudgesEnabled:
                                      _preferences!.focusZenNudgesEnabled,
                                  socialInteractionsEnabled:
                                      _preferences!.socialInteractionsEnabled,
                                  actionRemindersEnabled:
                                      _preferences!.actionRemindersEnabled,
                                  aiCoachEnabled: value,
                                  inAppEnabled: _preferences!.inAppEnabled,
                                  emailEnabled: _preferences!.emailEnabled,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled:
                                      _preferences!.doNotDisturbEnabled,
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Delivery Channels
                          const Text(
                            'Delivery Channels',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _PreferenceSwitch(
                            title: 'In-App Notifications',
                            description: 'Notifications within the app',
                            icon: Icons.notifications_rounded,
                            value: _preferences!.inAppEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled:
                                      _preferences!.achievementsEnabled,
                                  focusZenNudgesEnabled:
                                      _preferences!.focusZenNudgesEnabled,
                                  socialInteractionsEnabled:
                                      _preferences!.socialInteractionsEnabled,
                                  actionRemindersEnabled:
                                      _preferences!.actionRemindersEnabled,
                                  aiCoachEnabled: _preferences!.aiCoachEnabled,
                                  inAppEnabled: value,
                                  emailEnabled: _preferences!.emailEnabled,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled:
                                      _preferences!.doNotDisturbEnabled,
                                );
                              });
                            },
                          ),
                          _PreferenceSwitch(
                            title: 'Email Notifications',
                            description: 'Receive notifications via email',
                            icon: Icons.email_rounded,
                            value: _preferences!.emailEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled:
                                      _preferences!.achievementsEnabled,
                                  focusZenNudgesEnabled:
                                      _preferences!.focusZenNudgesEnabled,
                                  socialInteractionsEnabled:
                                      _preferences!.socialInteractionsEnabled,
                                  actionRemindersEnabled:
                                      _preferences!.actionRemindersEnabled,
                                  aiCoachEnabled: _preferences!.aiCoachEnabled,
                                  inAppEnabled: _preferences!.inAppEnabled,
                                  emailEnabled: value,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled:
                                      _preferences!.doNotDisturbEnabled,
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Quiet Hours
                          const Text(
                            'Quiet Hours',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _TimePicker(
                                        label: 'Start',
                                        value: _preferences!.quietHoursStart ??
                                            '21:00',
                                        onChanged: (value) {
                                          setState(() {
                                            _preferences =
                                                NotificationPreference(
                                              userId: widget.userId,
                                              achievementsEnabled: _preferences!
                                                  .achievementsEnabled,
                                              focusZenNudgesEnabled:
                                                  _preferences!
                                                      .focusZenNudgesEnabled,
                                              socialInteractionsEnabled:
                                                  _preferences!
                                                      .socialInteractionsEnabled,
                                              actionRemindersEnabled:
                                                  _preferences!
                                                      .actionRemindersEnabled,
                                              aiCoachEnabled:
                                                  _preferences!.aiCoachEnabled,
                                              inAppEnabled:
                                                  _preferences!.inAppEnabled,
                                              emailEnabled:
                                                  _preferences!.emailEnabled,
                                              quietHoursStart: value,
                                              quietHoursEnd:
                                                  _preferences!.quietHoursEnd,
                                              doNotDisturbEnabled: _preferences!
                                                  .doNotDisturbEnabled,
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _TimePicker(
                                        label: 'End',
                                        value: _preferences!.quietHoursEnd ??
                                            '08:00',
                                        onChanged: (value) {
                                          setState(() {
                                            _preferences =
                                                NotificationPreference(
                                              userId: widget.userId,
                                              achievementsEnabled: _preferences!
                                                  .achievementsEnabled,
                                              focusZenNudgesEnabled:
                                                  _preferences!
                                                      .focusZenNudgesEnabled,
                                              socialInteractionsEnabled:
                                                  _preferences!
                                                      .socialInteractionsEnabled,
                                              actionRemindersEnabled:
                                                  _preferences!
                                                      .actionRemindersEnabled,
                                              aiCoachEnabled:
                                                  _preferences!.aiCoachEnabled,
                                              inAppEnabled:
                                                  _preferences!.inAppEnabled,
                                              emailEnabled:
                                                  _preferences!.emailEnabled,
                                              quietHoursStart:
                                                  _preferences!.quietHoursStart,
                                              quietHoursEnd: value,
                                              doNotDisturbEnabled: _preferences!
                                                  .doNotDisturbEnabled,
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Do Not Disturb
                          _PreferenceSwitch(
                            title: 'Do Not Disturb',
                            description:
                                'Pause all notifications (except critical)',
                            icon: Icons.notifications_off_rounded,
                            value: _preferences!.doNotDisturbEnabled,
                            onChanged: (value) {
                              setState(() {
                                _preferences = NotificationPreference(
                                  userId: widget.userId,
                                  achievementsEnabled:
                                      _preferences!.achievementsEnabled,
                                  focusZenNudgesEnabled:
                                      _preferences!.focusZenNudgesEnabled,
                                  socialInteractionsEnabled:
                                      _preferences!.socialInteractionsEnabled,
                                  actionRemindersEnabled:
                                      _preferences!.actionRemindersEnabled,
                                  aiCoachEnabled: _preferences!.aiCoachEnabled,
                                  inAppEnabled: _preferences!.inAppEnabled,
                                  emailEnabled: _preferences!.emailEnabled,
                                  quietHoursStart:
                                      _preferences!.quietHoursStart,
                                  quietHoursEnd: _preferences!.quietHoursEnd,
                                  doNotDisturbEnabled: value,
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _savePreferences,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Save Preferences'),
                            ),
                          ),
                        ],
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

class _PreferenceSwitch extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceSwitch({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF2A2A2A),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TimePicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final parts = value.split(':');
            final initialTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
            final picked = await showTimePicker(
              context: context,
              initialTime: initialTime,
            );
            if (picked != null) {
              onChanged(
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.access_time, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
