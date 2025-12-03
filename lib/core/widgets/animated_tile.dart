import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Animated tile with hover and press effects
class AnimatedTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final double hoverScale;
  final double pressScale;

  const AnimatedTile({
    super.key,
    required this.child,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hoverScale = 1.02,
    this.pressScale = 0.98,
  });

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _handleExit(PointerExitEvent event) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final currentScale = _isPressed
        ? widget.pressScale
        : (_isHovered ? _scaleAnimation.value : 1.0);

    return MouseRegion(
      onEnter: _handleEnter,
      onExit: _handleExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(currentScale),
          child: widget.child,
        ),
      ),
    );
  }
}
