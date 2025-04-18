import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/bloc/model_picker_bloc.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/bloc/model_picker_state.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_type.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(GetChatHistoryEvent());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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

    context.read<ChatBloc>().add(SendMessageEvent(message: message));
    setState(() {
      _isActive = false;
    });
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
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return BlocListener<ModelPickerBloc, ModelPickerState>(
      listener: (context, state) {
        if (state is ModelPickerLoaded) {
          // Update the model path in the chat bloc
          print('Model path: ${state.modelPath}');
          context.read<ChatBloc>().add(
            InitializeModelEvent(modelPath: state.modelPath!),
          );
        }
        if (state is ModelPickerError) {
          // Handle error state
          print('Error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<ChatBloc, ChatState>(
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

            // Auto-scroll when new content is added
            if (currentResponse.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            }
          } else if (state is ChatError) {
            errorMessage = state.message;
          }

          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 1,
              elevation: 0,
              shadowColor: colorScheme.shadow.withOpacity(0.1),
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              // Ensure title row doesn't overflow
              title: Row(
                mainAxisSize:
                    MainAxisSize.min, // Prevent row from taking max width
                children: [
                  Flexible(
                    // Allow title to shrink
                    child: Text(
                      AppConstants.chatScreenTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle overflow
                      maxLines: 1,
                    ),
                  ),
                  // Add spacing before badges
                  if (modelType == ModelType.openAi ||
                      (modelType == ModelType.local && isReady))
                    const SizedBox(width: 8),
                  // Badges (conditionally shown)
                  if (modelType == ModelType.openAi)
                    _buildModelBadge(colorScheme),
                  if (modelType == ModelType.local && isReady)
                    _buildLocalModelBadge(colorScheme),
                ],
              ),
              actions: [
                if (modelType == ModelType.local)
                  IconButton(
                    icon: const Icon(Icons.folder_open_rounded),
                    tooltip: 'Change Local Model',
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.all(
                        10,
                      ), // Slightly reduced padding
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModelPickerPage(),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: 'Settings',
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.all(
                      10,
                    ), // Slightly reduced padding
                  ),
                  onPressed: _openSettings,
                ),
                _buildOptionsMenu(colorScheme, modelType),
                const SizedBox(width: 4), // Add slight padding at the end
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Error message display
                  if (state is ChatError)
                    _buildErrorMessage(colorScheme, errorMessage),

                  // Chat messages area
                  Expanded(
                    child: _buildChatContent(
                      isReady: isReady,
                      colorScheme: colorScheme,
                      messages: messages,
                      currentResponse: currentResponse,
                    ),
                  ),

                  // Message input area
                  _buildMessageInput(colorScheme, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModelBadge(ColorScheme colorScheme) {
    return Container(
      // Reduced margin slightly
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12), // Smaller radius
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 11, // Smaller icon
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'OpenAI',
            style: TextStyle(
              fontSize: 11, // Smaller font
              fontWeight: FontWeight.bold,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalModelBadge(ColorScheme colorScheme) {
    return Container(
      // Reduced margin slightly
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12), // Smaller radius
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.memory_rounded,
            size: 11, // Smaller icon
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Local',
            style: TextStyle(
              fontSize: 11, // Smaller font
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(ColorScheme colorScheme, ModelType modelType) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert_rounded),
      position: PopupMenuPosition.under,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder:
          (context) => [
            if (modelType == ModelType.openAi)
              PopupMenuItem(
                value: 'switchToLocal',
                child: _buildMenuItem(
                  icon: Icons.computer_rounded,
                  text: 'Switch to Local Model',
                  colorScheme: colorScheme,
                ),
              ),
            PopupMenuItem(
              value: 'clearChat',
              child: _buildMenuItem(
                icon: Icons.cleaning_services_rounded,
                text: 'Clear Chat',
                colorScheme: colorScheme,
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'switchToLocal':
            _selectLocalModel();
            break;
          case 'clearChat':
            context.read<ChatBloc>().add(ClearChatEvent());
            break;
        }
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ColorScheme colorScheme, String errorMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: $errorMessage',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: colorScheme.onErrorContainer,
              size: 18,
            ),
            onPressed: () {
              context.read<ChatBloc>().add(GetChatHistoryEvent());
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent({
    required bool isReady,
    required ColorScheme colorScheme,
    required List<Message> messages,
    required String currentResponse,
  }) {
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
    } else if (messages.isEmpty) {
      return _buildEmptyChatView(colorScheme);
    } else {
      return ListView.builder(
        controller: _scrollController,
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
          return MessageBubble(message: messages[index]);
        },
      );
    }
  }

  Widget _buildEmptyChatView(ColorScheme colorScheme) {
    return Center(
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
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ColorScheme colorScheme, ChatState state) {
    final bool isLoading = state is ChatLoading;
    final bottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 120, // Limit max height to prevent extreme expansion
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  enabled: _isActive,
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && state is! ChatLoading) {
                      _sendMessage();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 46,
            height: 46,
            child: Material(
              color:
                  isLoading ? colorScheme.surfaceVariant : colorScheme.primary,
              borderRadius: BorderRadius.circular(23),
              elevation: 0,
              child: InkWell(
                onTap: isLoading ? null : _sendMessage,
                borderRadius: BorderRadius.circular(23),
                child: Icon(
                  isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                  color:
                      isLoading
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
