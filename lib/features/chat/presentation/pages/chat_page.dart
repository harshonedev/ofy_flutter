import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.sendMessage(message);
    _messageController.clear();

    // Scroll to the bottom after the message is sent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final messages = provider.messages;
        final currentResponse = provider.currentResponse;
        final isReady = provider.state == ChatState.ready;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (isReady) {
              if (context.mounted) Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text(AppConstants.chatScreenTitle)),
            body: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // Scroll to bottom when new messages arrive
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            messages.length +
                            (currentResponse.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < messages.length) {
                            final message = messages[index];
                            return MessageBubble(message: message);
                          } else {
                            // Show the current response as it comes in
                            return MessageBubble(
                              message: Message(
                                content: currentResponse,
                                role: MessageRole.assistant,
                              ),
                              isTyping: true,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                Builder(
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: AppConstants.messageHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              enabled: isReady,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: isReady ? _sendMessage : null,
                            icon: const Icon(Icons.send),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
