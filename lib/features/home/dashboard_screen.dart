import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../checkin/sequential_checkin_screen.dart';
import '../reports/analytics_screen.dart';
import '../learning/learning_hub_screen.dart';
import '../learning/skill_sparks_screen.dart';
import '../learning/brain_forge_screen.dart';
import '../learning/thought_circles_screen.dart';
import '../learning/idea_lab_screen.dart';
import '../learning/focus_zone_screen.dart';
import '../learning/mind_balance_screen.dart';
import '../culture/inside_rbm_screen.dart';
import '../meetings/meeting_room_screen.dart';
import '../future_me/future_me_screen.dart';
import '../auth/login_screen.dart';
import '../onboarding/app_tour_service.dart';
import '../admin/role_designation_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/animated_tile.dart';
import '../../core/animations/fade_in_animation.dart';
import '../../core/utils/navigation_helper.dart';
import 'services/dashboard_service.dart';

const logoAsset = 'assets/logo/rbm-logo.svg';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final String role;
  final Future<void> Function()? onLogout;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.role,
    this.onLogout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();
  Map<String, dynamic> _userStats = {};
  Map<String, dynamic> _growthScore = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final stats = await _service.getUserStats(widget.userId);
      final growth = await _service.getGrowthScore(widget.userId);
      if (mounted) {
        setState(() {
          _userStats = stats;
          _growthScore = growth;
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
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      drawer: AppDrawer(
        userId: widget.userId,
        role: widget.role,
        onLogout: widget.onLogout,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            // Header
            AppHeader(
              title: 'RBM-Pulse Dashboard',
              showMenu: true,
              showBackButton: false, // Dashboard is root, no back button
              userId: widget.userId, // Enable notifications
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFE0E0E0)
                                  : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFF3A3A3A),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.waving_hand,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xFF6C6C6C)
                                  : Colors.white70,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? const Color(0xFF2C2C2C)
                                        : Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choose an option to get started',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? const Color(0xFF6C6C6C)
                                        : Colors.white70,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Growth Score Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFE0E0E0)
                                  : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Growth Score',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFF6C6C6C)
                                      : Colors.white70,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_growthScore['score'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              Text(
                                'Level ${_growthScore['level'] ?? 1} • ${_growthScore['xpToNext'] ?? 100} XP to next',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFF6C6C6C)
                                      : Colors.white70,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFF3A3A3A),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              size: 24,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xFF6C6C6C)
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5 Growth Modules - Compact stylish tiles with animations
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                      children: [
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 100),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const SkillSparksScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Skill Sparks',
                              subtitle: 'Micro-Learning',
                              icon: Icons.bolt_rounded,
                              color: const Color(0xFF4A4A4A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 150),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const BrainForgeScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Brain Forge',
                              subtitle: 'IQ Games',
                              icon: Icons.extension_rounded,
                              color: const Color(0xFF5A5A5A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const ThoughtCirclesScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Thought Circles',
                              subtitle: 'AI Discussions',
                              icon: Icons.forum_rounded,
                              color: const Color(0xFF4A4A4A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 250),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const IdeaLabScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Idea Lab',
                              subtitle: 'Innovation',
                              icon: Icons.science_rounded,
                              color: const Color(0xFF3A3A3A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const FocusZoneScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Focus Zone',
                              subtitle: 'Detox Mode',
                              icon: Icons.shield_rounded,
                              color: const Color(0xFF5A5A5A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 350),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const MindBalanceScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Mind Balance',
                              subtitle: 'Emotional Wellness',
                              icon: Icons.self_improvement_rounded,
                              color: const Color(0xFF4A4A4A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const InsideRbmScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Inside RBM',
                              subtitle: 'Culture Feed',
                              icon: Icons.people_rounded,
                              color: const Color(0xFF3A3A3A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 450),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const MeetingRoomScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Meeting Room',
                              subtitle: 'Action Intelligence',
                              icon: Icons.meeting_room_rounded,
                              color: const Color(0xFF5A5A5A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              const FutureMeScreen(),
                            ),
                            child: _DashboardTile(
                              title: 'Future Me',
                              subtitle: 'AI Growth Twin',
                              icon: Icons.auto_awesome_rounded,
                              color: const Color(0xFF4A4A4A),
                              onTap: () {},
                            ),
                          ),
                        ),
                        if (widget.role != 'employee')
                          FadeInAnimation(
                            delay: const Duration(milliseconds: 550),
                            child: AnimatedTile(
                              onTap: () => NavigationHelper.pushSlide(
                                context,
                                AdminDashboardScreen(
                                  userId: widget.userId,
                                  role: widget.role,
                                ),
                              ),
                              child: _DashboardTile(
                                title: 'Admin Console',
                                subtitle: 'Leadership Dashboard',
                                icon: Icons.admin_panel_settings_rounded,
                                color: const Color(0xFF2A2A2A),
                                onTap: () {},
                              ),
                            ),
                          ),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 600),
                          child: AnimatedTile(
                            onTap: () => NavigationHelper.pushSlide(
                              context,
                              SequentialCheckinScreen(profileId: widget.userId),
                            ),
                            child: _DashboardTile(
                              title: 'Pulse Survey',
                              subtitle: 'Daily Check-in',
                              icon: Icons.assessment_rounded,
                              color: const Color(0xFFD72631),
                              onTap: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF5F5F5) : color;
    final textColor = isLight ? const Color(0xFF2C2C2C) : Colors.white;
    final iconColor = isLight ? const Color(0xFF6C6C6C) : Colors.white70;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isLight ? const Color(0xFFE0E0E0) : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textColor,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: isLight ? const Color(0xFF6C6C6C) : Colors.white70,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
