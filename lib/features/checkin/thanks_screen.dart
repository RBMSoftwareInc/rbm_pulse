// lib/features/checkin/thanks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _logoAsset = 'assets/logo/rbm-logo.svg';

class ThanksScreen extends StatelessWidget {
  final double burnoutScore;
  final double engagementScore;
  final String moodSummary;
  final List<String> personalTips;
  final String color;

  const ThanksScreen({
    super.key,
    required this.burnoutScore,
    required this.engagementScore,
    required this.moodSummary,
    required this.personalTips,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor;
    IconData barIcon;
    String encouragement;
    if (burnoutScore > 70) {
      barColor = Colors.red;
      barIcon = Icons.warning_rounded;
      encouragement =
          "It looks like you might be feeling high workplace stress or burnout. Let's work together for support and balance!";
    } else if (burnoutScore > 40) {
      barColor = Colors.orange;
      barIcon = Icons.info_outline_rounded;
      encouragement =
          "You're in a moderate stress zone; keep checking in and use available resources.";
    } else {
      barColor = Colors.green;
      barIcon = Icons.check_circle_outline_rounded;
      encouragement =
          "You're showing healthy mood and engagement. Stay connected to your strengths!";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Success Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            barColor.withOpacity(0.3),
                            barColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: barColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Check-In Complete",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Burnout Score Card
                    _buildScoreCard(
                      context: context,
                      title: "Burnout Risk",
                      score: burnoutScore,
                      maxScore: 100,
                      color: barColor,
                      icon: barIcon,
                      label: _getBurnoutLabel(burnoutScore),
                    ),
                    const SizedBox(height: 20),
                    // Engagement Score Card
                    _buildScoreCard(
                      context: context,
                      title: "Engagement",
                      score: engagementScore,
                      maxScore: 100,
                      color: Colors.greenAccent,
                      icon: Icons.trending_up_rounded,
                      label: _getEngagementLabel(engagementScore),
                    ),
                    const SizedBox(height: 24),
                    // Mood Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology_outlined,
                              color: Colors.blueAccent, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              moodSummary,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Encouragement Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            barColor.withOpacity(0.15),
                            barColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: barColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(barIcon, color: barColor, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  encouragement,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (personalTips.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 12),
                            ...personalTips.map((tip) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.emoji_emotions_rounded,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD72631), Color(0xFF8B1A1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: SvgPicture.asset(
                _logoAsset,
                height: 24,
                width: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'RBM-Pulse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => _navigateHome(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _navigateHome(context),
            icon: const Icon(Icons.home_rounded),
            label: const Text(
              "Go Home",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD72631),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required BuildContext context,
    required String title,
    required double score,
    required double maxScore,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    final percentage = (score / maxScore).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          score.toStringAsFixed(1),
                          style: TextStyle(
                            color: color,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / $maxScore',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getBurnoutLabel(double score) {
    if (score >= 70) return 'High Risk • Support Recommended';
    if (score >= 40) return 'Moderate Risk • Monitor Closely';
    if (score >= 20) return 'Low Risk • Keep Monitoring';
    return 'Very Low Risk • Healthy Range';
  }

  String _getEngagementLabel(double score) {
    if (score >= 75) return 'Excellent • Highly Engaged';
    if (score >= 55) return 'Good • Well Engaged';
    if (score >= 40) return 'Moderate • Room for Growth';
    return 'Low • Needs Attention';
  }

  void _navigateHome(BuildContext context) {
    // Navigate all the way back to the dashboard/home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
