import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../animations/page_transitions.dart';
import '../../features/home/dashboard_screen.dart';

/// Helper class for smooth navigation with animations
class NavigationHelper {
  /// Navigate with slide animation
  static Future<T?> pushSlide<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      SlidePageRoute(page: page),
    );
  }

  /// Navigate with fade animation
  static Future<T?> pushFade<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      FadePageRoute(page: page),
    );
  }

  /// Navigate with scale animation
  static Future<T?> pushScale<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      ScalePageRoute(page: page),
    );
  }

  /// Navigate to dashboard (used after login)
  static void navigateToDashboard(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      SlidePageRoute(
        page: DashboardScreen(
          userId: userId,
          role: 'employee', // This should be fetched from profile
          onLogout: () async {
            await Supabase.instance.client.auth.signOut();
          },
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
