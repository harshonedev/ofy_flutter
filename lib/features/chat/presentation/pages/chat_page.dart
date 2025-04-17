import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_type.dart';
import '../../../../core/di/injection_container.dart';
import '../../../model_picker/presentation/pages/model_picker_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
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
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(GetChatHistoryEvent());
  }

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

    context.read<ChatBloc>().add(
      SendMessageEvent(
        message: message,
        // Get model path from dependencies if needed
        // modelPath: sl<ModelPathProvider>().modelPath,
      ),
    );
    _messageController.clear();

    // Scroll to the bottom after the message is sent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _selectLocalModel() {
    context.read<ChatBloc>().add(
      const SwitchModelTypeEvent(useLocalModel: true),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ModelPickerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        bool isReady = false;
        ModelType modelType = ModelType.local;
        List<Message> messages = [];
        String currentResponse = '';
        String errorMessage = '';

        if (state is ChatLoaded) {
          isReady = true;
          modelType = state.modelType;
          messages = state.messages;
          currentResponse = state.currentResponse ?? '';
        } else if (state is ChatError) {
          errorMessage = state.message;
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (isReady) {
              if (context.mounted) Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const Text(AppConstants.chatScreenTitle),
                  if (modelType == ModelType.openAi)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'OpenAI',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              actions: [
                if (modelType == ModelType.local)
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: 'Change Local Model',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModelPickerPage(),
                        ),
                      );
                    },
                  ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings, size: 20),
                              SizedBox(width: 8),
                              Text('Settings'),
                            ],
                          ),
                        ),
                        if (modelType == ModelType.openAi)
                          const PopupMenuItem(
                            value: 'switchToLocal',
                            child: Row(
                              children: [
                                Icon(Icons.computer, size: 20),
                                SizedBox(width: 8),
                                Text('Switch to Local Model'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'clearChat',
                          child: Row(
                            children: [
                              Icon(Icons.cleaning_services, size: 20),
                              SizedBox(width: 8),
                              Text('Clear Chat'),
                            ],
                          ),
                        ),
                      ],
                  onSelected: (value) {
                    switch (value) {
                      case 'settings':
                        _openSettings();
                        break;
                      case 'switchToLocal':
                        _selectLocalModel();
                        break;
                      case 'clearChat':
                        context.read<ChatBloc>().add(ClearChatEvent());
                        break;
                    }
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                if (state is ChatError)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    color: Colors.red.withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
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
