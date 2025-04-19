import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/bloc/model_picker_bloc.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/bloc/model_picker_state.dart';
import 'package:llm_cpp_chat_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:llm_cpp_chat_app/features/settings/presentation/bloc/settings_state.dart';
import '../../../../core/constants/model_type.dart';
import '../../../model_picker/presentation/pages/model_picker_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/chat_app_bar_actions.dart';
import '../widgets/chat_list_view.dart';
import '../widgets/error_message_display.dart';
import '../widgets/message_input_area.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  // bool _isActive = true; // State managed by MessageInputArea now

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
    // setState(() {
    //   _isActive = false; // No longer needed here
    // });
    _messageController.clear();
    _focusNode.unfocus(); // Unfocus after sending

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

  void _changeLocalModel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ModelPickerPage()),
    );
  }

  void _selectLocalModel() {
    _changeLocalModel(); // Navigate to picker
  }

  void _clearChat() {
    context.read<ChatBloc>().add(ClearChatEvent());
  }

  void _dismissError() {
    context.read<ChatBloc>().add(
      GetChatHistoryEvent(),
    ); // Or appropriate event to clear error
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<ModelPickerBloc, ModelPickerState>(
          listener: (context, state) {
            if (state is ModelPickerLoaded && state.modelPath != null) {
              // Update the model path in the chat bloc

              context.read<ChatBloc>().add(
                InitializeModelEvent(modelPath: state.modelPath!),
              );
            }
            if (state is ModelPickerError) {
              // Handle error state
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: colorScheme.error,
                ),
              );
              // Potentially navigate back or show error in ChatBloc
            }
          },
        ),

        BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded) {
              // Update settings in the chat bloc if needed
              context.read<ChatBloc>().add(
                SwitchModelTypeEvent(
                  modelType: state.modelType,
                  modelApiKey: state.getApiKey(state.modelType),
                  modelName: state.getModelName(state.modelType),
                ),
              );
            }
            if (state is SettingsError) {
              // Handle error state
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          bool isReady = false;
          bool isLoading = state is ChatLoading || state is ChatInitial;
          ModelType modelType = ModelType.local; // Default or from state
          List<Message> messages = [];
          String currentResponse = '';
          String errorMessage = '';
          bool isChatFinished = true;

          if (state is ChatLoaded) {
            isReady = true;
            modelType = state.modelType;
            messages = state.messages;
            currentResponse = state.currentResponse ?? '';
            isChatFinished = state.isChatFinished ?? true;

            // Auto-scroll when new content is added
            if (currentResponse.isNotEmpty || messages.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            }
          } else if (state is ChatError) {
            // Keep previous messages if available from a prior ChatLoaded state
            // This requires ChatError state to potentially hold previous messages
            // For simplicity now, we just show the error message.
            isReady = true; // Consider the UI ready to show the error
            messages = state.messages ?? [];
            errorMessage = state.message;
          } else if (state is ChatLoading) {
            isReady = true;
          }

          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 1,
              elevation: 0,
              shadowColor: colorScheme.shadow.withOpacity(0.1),
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              title: AppBarTitle(
                modelType: modelType,
                isReady: isReady, // Pass readiness for badge display
                colorScheme: colorScheme,
                theme: theme,
              ),
              actions: [
                ChatAppBarActions(
                  modelType: modelType,
                  colorScheme: colorScheme,
                  onSelectLocalModel: _selectLocalModel,
                  onChangeLocalModel: _changeLocalModel,
                  onOpenSettings: _openSettings,
                  onClearChat: _clearChat,
                ),
              ],
            ),
            body: SafeArea(
              bottom: false, // Let MessageInputArea handle bottom padding
              child: Column(
                children: [
                  // Error message display
                  if (errorMessage.isNotEmpty)
                    ErrorMessageDisplay(
                      errorMessage: errorMessage,
                      colorScheme: colorScheme,
                      onDismiss: _dismissError,
                    ),

                  // Chat messages area
                  Expanded(
                    child: ChatListView(
                      isReady: isReady,
                      messages: messages,
                      currentResponse: currentResponse,
                      scrollController: _scrollController,
                      colorScheme: colorScheme,
                    ),
                  ),

                  // Message input area
                  MessageInputArea(
                    messageController: _messageController,
                    focusNode: _focusNode,
                    isLoading: isLoading,
                    isChatFinished: isChatFinished,
                    isActive: !isLoading, // Input active when not loading
                    onSendMessage: _sendMessage,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
