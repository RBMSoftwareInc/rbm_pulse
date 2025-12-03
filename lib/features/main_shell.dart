// features/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'checkin/sequential_checkin_screen.dart';
import 'reports/analytics_screen.dart';
import 'history/history_screen.dart';
import 'gamification/streaks_screen.dart';
import 'tips/tips_screen.dart';

class MainShell extends StatefulWidget {
  final String role;
  final VoidCallback onLogout;
  final String userId;
  const MainShell({
    super.key,
    required this.role,
    required this.onLogout,
    required this.userId,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedTab =
      0; // 0: Check-in, 1: Analytics, 2: History, 3: Streaks, 4: Tips

  Widget getScreen() {
    switch (_selectedTab) {
      case 0:
        return SequentialCheckinScreen(profileId: widget.userId);
      case 1:
        return AnalyticsScreen();
      case 2:
        return HistoryScreen(profileId: widget.userId);
      case 3:
        return StreaksScreen(profileId: widget.userId);
      case 4:
        return const TipsScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBossOrHr =
        widget.role == 'admin' || widget.role == 'hr' || widget.role == 'boss';
    return Scaffold(
      appBar: AppBar(
        title: Text([
          'Check-in',
          'Analytics',
          'History',
          'Streaks',
          'Tips'
        ][_selectedTab]),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout)
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFFD72631)),
                child:
                    SvgPicture.asset('assets/logo/rbm-logo.svg', height: 48)),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Check-in'),
              selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            if (isBossOrHr)
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Analytics'),
                selected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('My Check-in History'),
              selected: _selectedTab == 2,
              onTap: () => setState(() => _selectedTab = 2),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Achievements & Streaks'),
              selected: _selectedTab == 3,
              onTap: () => setState(() => _selectedTab = 3),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Wellness Tips'),
              selected: _selectedTab == 4,
              onTap: () => setState(() => _selectedTab = 4),
            ),
          ],
        ),
      ),
      body: getScreen(),
    );
  }
}
