import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isTyping;

  const MessageBubble({
    required this.message,
    this.isTyping = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == MessageRole.user;
    final chatProvider = Provider.of<ChatProvider>(context);

    // Only show typing indicator for the current response that's being generated
    final showTypingIndicator =
        isTyping &&
        chatProvider.isReceivingResponse &&
        chatProvider.state == ChatState.generating;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color:
              isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.content,
                  style: TextStyle(
                    color:
                        isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (showTypingIndicator) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 12,
                    width: 40,
                    child: LinearProgressIndicator(
                      backgroundColor: theme.colorScheme.onSurfaceVariant
                          .withAlpha(50),
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(125),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
