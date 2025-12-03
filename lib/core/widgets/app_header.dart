import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart' as provider;
import '../../core/theme/theme_provider.dart';
import '../../features/info/help_screen.dart';
import '../../features/info/about_screen.dart';
import '../../features/notifications/widgets/notification_badge.dart';
import '../../features/notifications/widgets/notification_panel.dart';
import '../../features/notifications/services/notification_service.dart';

const logoAsset = 'assets/logo/rbm-logo.svg';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onMenuTap;
  final bool showMenu;
  final String? userId; // For notification badge

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false, // Default to false - no back buttons
    this.onMenuTap,
    this.showMenu = true,
    this.userId,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppHeaderState extends State<AppHeader> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    if (widget.userId == null) return;
    final count = await _notificationService.getUnreadCount(widget.userId!);
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  void _showNotificationPanel() {
    if (widget.userId == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: NotificationPanel(
          userId: widget.userId!,
          onNotificationTap: _loadUnreadCount,
        ),
      ),
    ).then((_) => _loadUnreadCount());
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Theme'),
              trailing: provider.Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms of Service'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to terms
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms of Service coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Send Feedback'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open feedback form
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback form coming soon')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFD72631),
      elevation: 0,
      leading: widget.showMenu
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: widget.onMenuTap ??
                  () {
                    Scaffold.of(context).openDrawer();
                  },
            )
          : widget.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
      title: Row(
        children: [
          Container(
            height: 40,
            width: 40,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (widget.userId != null)
          IconButton(
            icon: NotificationBadge(
              count: _unreadCount,
              child:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
            ),
            onPressed: _showNotificationPanel,
          ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showMoreMenu(context),
        ),
        if (widget.actions != null) ...widget.actions!,
      ],
    );
  }
}
