import 'package:flutter/material.dart';

class ThemeAnimations {
  static Widget heartbeatEffect(Widget child) {
    return HeartbeatEffect(child);
  }
}

class HeartbeatEffect extends StatefulWidget {
  final Widget child;

  const HeartbeatEffect(this.child, {super.key});

  @override
  _HeartbeatEffectState createState() => _HeartbeatEffectState();
}

class _HeartbeatEffectState extends State<HeartbeatEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true); // Repeating for heartbeat effect

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
