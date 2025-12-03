import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';

class BreakReminderScreen extends StatefulWidget {
  const BreakReminderScreen({super.key});

  @override
  State<BreakReminderScreen> createState() => _BreakReminderScreenState();
}

class _BreakReminderScreenState extends State<BreakReminderScreen> {
  bool _remindersEnabled = true;
  int _intervalMinutes = 90;
  bool _microBreaksEnabled = true;
  int _microBreakMinutes = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Break Reminders'),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.notifications_active_rounded,
                            size: 48,
                            color: Color(0xFFE74C3C),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Healthy Work Patterns',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Regular breaks improve productivity and reduce burnout',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      value: _remindersEnabled,
                      onChanged: (value) {
                        setState(() => _remindersEnabled = value);
                      },
                      title: const Text(
                        'Enable Break Reminders',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Get notified to take breaks',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      activeColor: const Color(0xFFE74C3C),
                    ),
                    if (_remindersEnabled) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.white.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Break Interval',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$_intervalMinutes minutes',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE74C3C),
                                ),
                              ),
                              Slider(
                                value: _intervalMinutes.toDouble(),
                                min: 30,
                                max: 180,
                                divisions: 10,
                                label: '$_intervalMinutes minutes',
                                activeColor: const Color(0xFFE74C3C),
                                onChanged: (value) {
                                  setState(() {
                                    _intervalMinutes = value.round();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SwitchListTile(
                      value: _microBreaksEnabled,
                      onChanged: (value) {
                        setState(() => _microBreaksEnabled = value);
                      },
                      title: const Text(
                        'Micro Breaks',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Short breaks every $_microBreakMinutes minutes',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      activeColor: const Color(0xFFE74C3C),
                    ),
                    if (_microBreaksEnabled) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.white.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Micro Break Duration',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$_microBreakMinutes minutes',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE74C3C),
                                ),
                              ),
                              Slider(
                                value: _microBreakMinutes.toDouble(),
                                min: 5,
                                max: 30,
                                divisions: 5,
                                label: '$_microBreakMinutes minutes',
                                activeColor: const Color(0xFFE74C3C),
                                onChanged: (value) {
                                  setState(() {
                                    _microBreakMinutes = value.round();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Break reminders configured!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Settings'),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
