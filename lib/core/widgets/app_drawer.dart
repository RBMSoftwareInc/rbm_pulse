import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/checkin/sequential_checkin_screen.dart';
import '../../features/reports/analytics_screen.dart';
import '../../features/learning/learning_hub_screen.dart';
import '../../features/admin/role_designation_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/onboarding/app_tour_service.dart';

const logoAsset = 'assets/logo/rbm-logo.svg';

class AppDrawer extends StatelessWidget {
  final String userId;
  final String role;
  final Future<void> Function()? onLogout;

  const AppDrawer({
    super.key,
    required this.userId,
    required this.role,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isBossOrHr = role == 'hr' || role == 'admin' || role == 'boss';

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                userId,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              accountEmail: Text(
                role,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              currentAccountPicture: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  logoAsset,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFD72631),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              decoration: const BoxDecoration(color: Color(0xFFD72631)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.check_circle_outline, color: Colors.white),
              title: const Text(
                'Pulse Survey',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SequentialCheckinScreen(profileId: userId),
                  ),
                );
              },
            ),
            if (isBossOrHr)
              ListTile(
                leading: const Icon(Icons.analytics, color: Colors.white),
                title: const Text(
                  'Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Roboto',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalyticsScreen(),
                    ),
                  );
                },
              ),
            if (isBossOrHr)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white),
                title: const Text(
                  'Admin Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Roboto',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminDashboardScreen(
                        userId: userId,
                        role: role,
                      ),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.school_rounded, color: Colors.white),
              title: const Text(
                'Learning Hub',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LearningHubScreen(),
                  ),
                );
              },
            ),
            // Role & Designation only for HR/Admin
            if (isBossOrHr)
              ListTile(
                leading: const Icon(Icons.work_outline, color: Colors.white),
                title: const Text(
                  'Role & Designation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Roboto',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoleDesignationScreen(
                        userId: userId,
                        currentRole: role,
                      ),
                    ),
                  );
                },
              ),
            const Divider(color: Colors.white70),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text(
                'My History',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to history screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History screen coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_outline, color: Colors.white),
              title: const Text(
                'Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to achievements screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Achievements screen coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white),
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings screen coming soon')),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to notifications screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Notifications screen coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white),
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile screen coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: const Text(
                'App Tour',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await AppTourService.showAppTour(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Roboto',
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                if (onLogout != null) {
                  await onLogout!();
                } else {
                  await Supabase.instance.client.auth.signOut();
                }
                if (context.mounted) {
                  // Navigate to login and clear navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(onLogin: () {}),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
