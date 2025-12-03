import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_footer.dart';

class ConfigControlScreen extends StatelessWidget {
  const ConfigControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Configuration & Control'),
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
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Super Admin only: System-wide configuration and control settings.',
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

                    // Feature Toggles
                    const Text(
                      'Feature Toggles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ConfigSwitch(
                      title: 'AR Experiences',
                      description: 'Enable augmented reality features',
                      icon: Icons.view_in_ar_rounded,
                      value: true,
                    ),
                    const _ConfigSwitch(
                      title: 'Meeting Recording',
                      description: 'Allow audio recording in Meeting Room',
                      icon: Icons.mic_rounded,
                      value: true,
                    ),
                    const _ConfigSwitch(
                      title: 'Anonymous Mode',
                      description: 'Enable anonymous survey responses',
                      icon: Icons.visibility_off_rounded,
                      value: false,
                    ),
                    const SizedBox(height: 24),

                    // Organization Settings
                    const Text(
                      'Organization Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ConfigCard(
                      title: 'Company Values Library',
                      description:
                          'Manage organization values and culture principles',
                      icon: Icons.workspace_premium_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Values library editor coming soon')),
                        );
                      },
                    ),
                    _ConfigCard(
                      title: 'Seasonal Themes & Banners',
                      description:
                          'Configure app themes and promotional banners',
                      icon: Icons.palette_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Theme editor coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // System Settings (Super Admin Only)
                    const Text(
                      'System Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ConfigCard(
                      title: 'Database Backup & Export',
                      description:
                          'Configure automated backups and data export',
                      icon: Icons.backup_rounded,
                      color: Colors.red,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Backup settings coming soon')),
                        );
                      },
                    ),
                    _ConfigCard(
                      title: 'Login & SSO Control',
                      description:
                          'Manage authentication methods and SSO configuration',
                      icon: Icons.lock_rounded,
                      color: Colors.red,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('SSO settings coming soon')),
                        );
                      },
                    ),
                    _ConfigCard(
                      title: 'App Update Notifications',
                      description:
                          'Configure update notifications and version control',
                      icon: Icons.system_update_rounded,
                      color: Colors.red,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Update settings coming soon')),
                        );
                      },
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

class _ConfigSwitch extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool value;

  const _ConfigSwitch({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
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
        onChanged: (newValue) {
          // TODO: Save to database
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('$title ${newValue ? "enabled" : "disabled"}')),
          );
        },
        activeColor: Colors.green,
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _ConfigCard({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (color ?? Colors.grey).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color ?? Colors.grey, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
