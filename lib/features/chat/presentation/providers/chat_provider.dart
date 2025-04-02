import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/model_service.dart';

enum ChatState { initial, loading, ready, error, generating }

class ChatProvider with ChangeNotifier {
  final ModelService _modelService = ModelService();
  final List<Message> _messages = [];
  ChatState _state = ChatState.initial;
  String _currentResponse = '';
  String _selectedModelPath = '';
  String _errorMessage = '';
  bool _isReceivingResponse = false;

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  ChatState get state => _state;
  String get currentResponse => _currentResponse;
  String get selectedModelPath => _selectedModelPath;
  String get errorMessage => _errorMessage;
  bool get isReceivingResponse => _isReceivingResponse;

  ChatProvider() {
    _initStreams();
  }

  void _initStreams() {
    _modelService.responseStream.listen(
      (response) {
        // Check if this is the completion marker
        if (response == ModelService.completionMaker) {
          _isReceivingResponse = false;
          _state = ChatState.ready;
          finalizeAssistantResponse();
          return;
        }

        _isReceivingResponse = true;
        _state = ChatState.generating;
        _currentResponse += response;
        notifyListeners();
      },
      onError: (error) {
        _state = ChatState.error;
        _errorMessage = error.toString();
        _isReceivingResponse = false;
        notifyListeners();
      },
      onDone: () {
        // This should only be called when the app is being disposed
        // or if there is a critical error
        debugPrint(
          "Chat Provider Stream Done - this is unexpected unless app is closing",
        );
        _isReceivingResponse = false;
        _state = ChatState.error;
        _errorMessage = "Connection to model lost. Please reload the model.";
        notifyListeners();
      },
    );
  }

  void _reinitializeStreams() {
    if (_selectedModelPath.isNotEmpty) {
      final currentPath = _selectedModelPath;
      loadModel(currentPath);
    }
  }

  Future<bool> loadModel(String modelPath) async {
    _state = ChatState.loading;
    _selectedModelPath = modelPath;
    _errorMessage = '';
    notifyListeners();

    final success = await _modelService.loadModel(modelPath);

    if (success) {
      _state = ChatState.ready;

      if (_messages.isEmpty) {
        addMessage(
          'Model loaded successfully. How can I help you today?',
          MessageRole.assistant,
        );
      }
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

    final userMessage = Message(content: content, role: MessageRole.user);
    _messages.add(userMessage);
    _state = ChatState.generating;
    notifyListeners();

    _currentResponse = '';

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

    addMessage(_currentResponse, MessageRole.assistant);
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
