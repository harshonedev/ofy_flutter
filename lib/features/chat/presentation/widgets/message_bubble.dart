import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isTyping;

  const MessageBubble({
    super.key,
    required this.message,
    this.isTyping = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUserMessage = widget.message.role == MessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    // Enhanced Material 3 colors with dynamic opacity for depth effect

    final messageTextColor =
        isUserMessage
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant;

    // Enhance the message bubble with a subtle gradient
    final gradientColors =
        isUserMessage
            ? [
              colorScheme.primaryContainer,
              Color.lerp(
                colorScheme.primaryContainer,
                colorScheme.primary,
                0.1,
              )!,
            ]
            : [
              colorScheme.surfaceVariant.withOpacity(0.85),
              colorScheme.surfaceVariant,
            ];

    return Padding(
      padding: EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
        left: isUserMessage ? 48.0 : 8.0,
        right: isUserMessage ? 8.0 : 48.0,
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Align(
          alignment:
              isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      isUserMessage
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                  bottomRight:
                      isUserMessage
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      widget.message.content,
                      style: TextStyle(
                        color: messageTextColor,
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(widget.message.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: messageTextColor.withOpacity(0.7),
                          ),
                        ),
                        if (widget.isTyping) ...[
                          const SizedBox(width: 6),
                          _buildTypingIndicator(colorScheme, isUserMessage),
                        ],
                        if (isUserMessage) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: messageTextColor.withOpacity(0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme, bool isUserMessage) {
    return SizedBox(
      width: 32,
      height: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return _AnimatedDot(
            index: index,
            color:
                isUserMessage
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primary,
          );
        }),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
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
