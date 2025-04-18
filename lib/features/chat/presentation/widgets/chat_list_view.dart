import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';
import 'message_bubble.dart';

class ChatListView extends StatelessWidget {
  final bool isReady;
  final List<Message> messages;
  final String currentResponse;
  final ScrollController scrollController;
  final ColorScheme colorScheme;

  const ChatListView({
    super.key,
    required this.isReady,
    required this.messages,
    required this.currentResponse,
    required this.scrollController,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading conversation...',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    } else if (messages.isEmpty && currentResponse.isEmpty) {
      return _buildEmptyChatView(colorScheme);
    } else {
      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        itemCount: messages.length + (currentResponse.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          // Show the current streaming response
          if (index == messages.length && currentResponse.isNotEmpty) {
            return MessageBubble(
              message: Message(
                content: currentResponse,
                role: MessageRole.assistant,
                timestamp: DateTime.now(),
              ),
              isTyping: true,
            );
          }

          // Show existing messages
          if (index < messages.length) {
            return MessageBubble(message: messages[index]);
          }
          return const SizedBox.shrink(); // Should not happen
        },
      );
    }
  }

  Widget _buildEmptyChatView(ColorScheme colorScheme) {
    // Wrap the Center widget with SingleChildScrollView
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          // Add padding to prevent sticking to edges when scrolling
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_outlined,
                  size: 72,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Start a conversation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Type a message to begin chatting',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
