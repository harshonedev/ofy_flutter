import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/model_service.dart';

enum ChatState { initial, loading, ready, error }

class ChatProvider with ChangeNotifier {
  final ModelService _modelService = ModelService();
  final List<Message> _messages = [];
  ChatState _state = ChatState.initial;
  String _currentResponse = '';
  String _selectedModelPath = '';
  String _errorMessage = '';

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  ChatState get state => _state;
  String get currentResponse => _currentResponse;
  String get selectedModelPath => _selectedModelPath;
  String get errorMessage => _errorMessage;

  ChatProvider() {
    _initStreams();
  }

  void _initStreams() {
    _modelService.responseStream.listen(
      (response) {
        _currentResponse += response;
        notifyListeners();
      },
      onError: (error) {
        _state = ChatState.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> loadModel(String modelPath) async {
    _state = ChatState.loading;
    _selectedModelPath = modelPath;
    _errorMessage = '';
    notifyListeners();

    final success = await _modelService.loadModel(modelPath);

    if (success) {
      _state = ChatState.ready;
      // Add a system welcome message
      addMessage(
        'Model loaded successfully. How can I help you today?',
        MessageRole.assistant,
      );
    } else {
      _state = ChatState.error;
      _errorMessage = 'Failed to load model';
    }

    notifyListeners();
    return success;
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (_state != ChatState.ready) return;

    // Add user message
    final userMessage = Message(content: content, role: MessageRole.user);
    _messages.add(userMessage);
    notifyListeners();

    // Reset current response
    _currentResponse = '';

    // Send the prompt to the model - just use the content directly
    try {
      await _modelService.sendPrompt(content);
    } catch (e) {
      _state = ChatState.error;
      _errorMessage = 'Error communicating with model: $e';
      notifyListeners();
    }
  }

  void finalizeAssistantResponse() {
    if (_currentResponse.trim().isEmpty) return;

    // Add assistant message with the complete response
    addMessage(_currentResponse, MessageRole.assistant);

    // Reset current response
    _currentResponse = '';
    notifyListeners();
  }

  void addMessage(String content, MessageRole role) {
    final message = Message(content: content, role: role);
    _messages.add(message);
    notifyListeners();
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }
}
