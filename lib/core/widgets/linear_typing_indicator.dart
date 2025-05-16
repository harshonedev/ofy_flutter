import 'package:flutter/material.dart';
import 'dart:math' as math;

class LinearTypingIndicator extends StatelessWidget {
  final bool isRight;
  const LinearTypingIndicator({super.key, this.isRight = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; 
    return SizedBox(
      width: 32,
      height: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return _AnimatedDot(
            index: index,
            color:
                isRight
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primary,
          );
        }),
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int index;
  final Color color;

  const _AnimatedDot({required this.index, required this.color});

  @override
  _AnimatedDotState createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    // Fix the interval to ensure end value doesn't exceed 1.0
    final double start = widget.index * 0.2;
    final double end = math.min(0.5 + widget.index * 0.2, 1.0);

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeInOut),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: 4,
          height: 4 + (_animation.value * 4),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.6 + (_animation.value * 0.4)),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }
}
