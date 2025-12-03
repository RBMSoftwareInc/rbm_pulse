import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/growth_data.dart';
import '../services/growth_service.dart';

class SkillTreeModeScreen extends StatefulWidget {
  final GrowthMetrics metrics;

  const SkillTreeModeScreen({
    super.key,
    required this.metrics,
  });

  @override
  State<SkillTreeModeScreen> createState() => _SkillTreeModeScreenState();
}

class _SkillTreeModeScreenState extends State<SkillTreeModeScreen> {
  final GrowthService _service = GrowthService();
  List<SkillNode> _nodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkillTree();
  }

  Future<void> _loadSkillTree() async {
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final nodes = await _service.getSkillTree(userId);
    setState(() {
      _nodes = nodes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Holographic Skill Map',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: CustomPaint(
                    painter: _SkillTreePainter(_nodes),
                    child: Container(),
                  ),
                ),
                const SizedBox(height: 24),
                // Legend
                const Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _LegendItem('Skills', Colors.blue),
                    _LegendItem('Cognitive', Colors.purple),
                    _LegendItem('Wellbeing', Colors.green),
                    _LegendItem('Collaboration', Colors.orange),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SkillTreePainter extends CustomPainter {
  final List<SkillNode> nodes;

  _SkillTreePainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;

    // Draw connections
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2;

    for (final node in nodes) {
      final nodeIndex = nodes.indexOf(node);
      final angle = (nodeIndex * 2 * math.pi / nodes.length) - math.pi / 2;
      final nodePos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      for (final connectedId in node.connectedNodeIds) {
        final connectedNode = nodes.firstWhere(
          (n) => n.id == connectedId,
          orElse: () => node,
        );
        final connectedIndex = nodes.indexOf(connectedNode);
        final connectedAngle =
            (connectedIndex * 2 * math.pi / nodes.length) - math.pi / 2;
        final connectedPos = Offset(
          center.dx + radius * math.cos(connectedAngle),
          center.dy + radius * math.sin(connectedAngle),
        );

        canvas.drawLine(nodePos, connectedPos, paint);
      }
    }

    // Draw nodes
    for (final node in nodes) {
      final nodeIndex = nodes.indexOf(node);
      final angle = (nodeIndex * 2 * math.pi / nodes.length) - math.pi / 2;
      final nodePos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final nodeColor = _getCategoryColor(node.category);
      final nodeRadius = 30.0 + (node.level / 100 * 20);

      // Glow effect for mastered nodes
      if (node.isMastered) {
        final glowPaint = Paint()
          ..color = nodeColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(nodePos, nodeRadius + 5, glowPaint);
      }

      // Node circle
      final nodePaint = Paint()
        ..color = nodeColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodePos, nodeRadius, nodePaint);

      // Border
      final borderPaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(nodePos, nodeRadius, borderPaint);

      // Node label
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          nodePos.dx - textPainter.width / 2,
          nodePos.dy + nodeRadius + 8,
        ),
      );

      // Level indicator
      final levelText = TextPainter(
        text: TextSpan(
          text: '${node.level.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      levelText.layout();
      levelText.paint(
        canvas,
        Offset(
          nodePos.dx - levelText.width / 2,
          nodePos.dy - nodeRadius - 12,
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'skill':
        return Colors.blue;
      case 'cognitive':
        return Colors.purple;
      case 'wellbeing':
        return Colors.green;
      case 'collaboration':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(_SkillTreePainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
