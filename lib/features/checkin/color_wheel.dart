import 'package:flutter/material.dart';
import 'dart:math' as math;

typedef ColorSelected = void Function(String colorName);

class ColorWheel extends StatefulWidget {
  final String selectedColor;
  final ColorSelected onSelected;

  const ColorWheel({
    super.key,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  State<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel>
    with SingleTickerProviderStateMixin {
  static const Map<String, Color> wheelColors = {
    'Green': Color(0xFF00FF88),
    'Blue': Color(0xFF00D4FF),
    'Yellow': Color(0xFFFFE500),
    'Orange': Color(0xFFFF8C00),
    'Red': Color(0xFFFF3B3B),
    'Purple': Color(0xFF9D4EDD),
    'Grey': Color(0xFF8E8E93),
    'Pink': Color(0xFFFF6B9D),
  };

  late AnimationController _rotationController;
  final double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: GestureDetector(
            onTapUp: (details) {
              final tapPos = details.localPosition;
              final center = const Offset(90, 90);
              final dx = tapPos.dx - center.dx;
              final dy = tapPos.dy - center.dy;

              // Calculate angle in degrees (0-360, where 0 is right, 90 is bottom)
              double angle = math.atan2(dy, dx) * 180 / math.pi;
              if (angle < 0) angle += 360;

              // Wheel starts at top (-90° or 270°), so adjust by adding 90° and wrapping
              // This aligns the angle with the wheel's starting position
              angle = (angle + 90) % 360;

              // Calculate which segment (each segment is 45 degrees)
              final segment = (angle ~/ 45) % wheelColors.length;
              final selected = wheelColors.keys.elementAt(segment);
              widget.onSelected(selected);
            },
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotation * math.pi / 180,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: wheelColors[widget.selectedColor]
                                  ?.withOpacity(0.3) ??
                              Colors.transparent,
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7],
                            ),
                          ),
                        ),
                        // Main wheel
                        CustomPaint(
                          size: const Size(180, 180),
                          painter: _GlossyWheelPainter(
                            wheelColors,
                            widget.selectedColor,
                          ),
                        ),
                        // Center highlight
                        IgnorePointer(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Center content
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.selectedColor.isEmpty
                                    ? Colors.white24
                                    : (wheelColors[widget.selectedColor]
                                            ?.withOpacity(0.2) ??
                                        Colors.white24),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.selectedColor.isEmpty
                                        ? Colors.transparent
                                        : (wheelColors[widget.selectedColor]
                                                ?.withOpacity(0.5) ??
                                            Colors.transparent),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _colorIcon(widget.selectedColor),
                                color: widget.selectedColor.isEmpty
                                    ? Colors.white54
                                    : (wheelColors[widget.selectedColor] ??
                                        Colors.white),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: widget.selectedColor.isEmpty
                                    ? Colors.white54
                                    : (wheelColors[widget.selectedColor] ??
                                        Colors.white),
                                shadows: [
                                  Shadow(
                                    color: widget.selectedColor.isEmpty
                                        ? Colors.transparent
                                        : (wheelColors[widget.selectedColor]
                                                ?.withOpacity(0.8) ??
                                            Colors.transparent),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.selectedColor.isEmpty
                                    ? 'Tap'
                                    : widget.selectedColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Compact color chips
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: wheelColors.entries.map((entry) {
            final isSelected = entry.key == widget.selectedColor;
            return Tooltip(
              message: _colorMeaning(entry.key),
              waitDuration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () => widget.onSelected(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? entry.value
                        : entry.value.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : entry.value.withOpacity(0.4),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: entry.value.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : entry.value,
                          boxShadow: [
                            BoxShadow(
                              color: entry.value.withOpacity(0.8),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _colorMeaning(String color) {
    switch (color) {
      case 'Green':
        return 'High engagement • energized + positive';
      case 'Blue':
        return 'Calm focus • thoughtful and steady';
      case 'Yellow':
        return 'Alert optimism • buzzing with ideas';
      case 'Orange':
        return 'Stretch zone • excited but pressured';
      case 'Red':
        return 'High stress • urgent attention needed';
      case 'Purple':
        return 'Reflective • introverted, low energy';
      case 'Grey':
        return 'Neutral • feeling flat or detached';
      case 'Pink':
        return 'Sensitive • seeking support or care';
      default:
        return '';
    }
  }

  IconData _colorIcon(String color) {
    if (color.isEmpty) return Icons.touch_app_rounded;
    switch (color) {
      case 'Green':
        return Icons.eco_rounded;
      case 'Blue':
        return Icons.water_drop_rounded;
      case 'Yellow':
        return Icons.wb_sunny_rounded;
      case 'Orange':
        return Icons.local_fire_department_rounded;
      case 'Red':
        return Icons.favorite_rounded;
      case 'Purple':
        return Icons.nightlight_round;
      case 'Grey':
        return Icons.cloud_rounded;
      case 'Pink':
        return Icons.favorite_border_rounded;
      default:
        return Icons.circle;
    }
  }
}

class _GlossyWheelPainter extends CustomPainter {
  final Map<String, Color> colors;
  final String selectedColor;

  _GlossyWheelPainter(this.colors, this.selectedColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    double startAngle = -math.pi / 2; // start top
    final sweepAngle = math.pi * 2 / colors.length;
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    colors.forEach((name, color) {
      final isSelected = name == selectedColor;
      final baseColor = isSelected ? color : color.withOpacity(0.65);

      // Main segment
      paint.color = baseColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Inner highlight for 3D effect
      if (isSelected) {
        highlightPaint.shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius * 0.7),
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.7),
          startAngle,
          sweepAngle,
          true,
          highlightPaint,
        );
      }

      // Segment divider
      paint.color = Colors.black.withOpacity(0.2);
      paint.strokeWidth = 1.5;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        ),
        paint,
      );
      paint.style = PaintingStyle.fill;

      startAngle += sweepAngle;
    });

    // Outer rim highlight
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, paint);
  }

  @override
  bool shouldRepaint(covariant _GlossyWheelPainter oldDelegate) =>
      oldDelegate.selectedColor != selectedColor;
}
