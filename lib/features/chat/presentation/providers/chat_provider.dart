import 'package:flutter/foundation.dart';
import '../../../../core/constants/model_type.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/model_service.dart';
import '../../domain/services/openai_service.dart';
import '../../../settings/data/repositories/settings_repository.dart';

enum ChatState { initial, loading, ready, error, generating }

class ChatProvider with ChangeNotifier {
  final ModelService _modelService = ModelService();
  final OpenAIService _openAIService = OpenAIService();
  final SettingsRepository _settingsRepository = SettingsRepository();

  final List<Message> _messages = [];
  ChatState _state = ChatState.initial;
  String _currentResponse = '';
  String _selectedModelPath = '';
  String _errorMessage = '';
  bool _isReceivingResponse = false;
  ModelType _modelType = ModelType.local;

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  ChatState get state => _state;
  String get currentResponse => _currentResponse;
  String get selectedModelPath => _selectedModelPath;
  String get errorMessage => _errorMessage;
  bool get isReceivingResponse => _isReceivingResponse;
  ModelType get modelType => _modelType;

  ChatProvider() {
    _initServices();
  }

  Future<void> _initServices() async {
    // Initialize model streams
    _initModelStream();
    _initOpenAIStream();

    // Load saved model type preference
    _modelType = await _settingsRepository.getModelTypePreference();
    notifyListeners();

    // If OpenAI is selected, initialize the OpenAI service
    if (_modelType == ModelType.openAi) {
      await _initializeOpenAI();
    }
  }

  void _initModelStream() {
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
        debugPrint(
          "Local Model Stream Done - this is unexpected unless app is closing",
        );
        _isReceivingResponse = false;
        _state = ChatState.error;
        _errorMessage = "Connection to model lost. Please reload the model.";
        notifyListeners();
      },
    );
  }

  void _initOpenAIStream() {
    _openAIService.responseStream.listen(
      (response) {
        // Check if this is the completion marker
        if (response == OpenAIService.completionMaker) {
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
        debugPrint("OpenAI Stream Done");
        _isReceivingResponse = false;
        _state = ChatState.error;
        _errorMessage = "Connection to OpenAI lost.";
        notifyListeners();
      },
    );
  }

  Future<void> _initializeOpenAI() async {
    final apiKey = await _settingsRepository.getOpenAiApiKey();
    final model = await _settingsRepository.getOpenAiModel();

    if (apiKey != null && apiKey.isNotEmpty) {
      _openAIService.initialize(apiKey, model);
      _state = ChatState.ready;

      if (_messages.isEmpty) {
        addMessage(
          'OpenAI model connected successfully. How can I help you today?',
          MessageRole.assistant,
        );
      }
      notifyListeners();
    } else {
      _state = ChatState.error;
      _errorMessage =
          'OpenAI API key not configured. Please add it in settings.';
      notifyListeners();
    }
  }

  Future<bool> loadModel(String modelPath) async {
    _state = ChatState.loading;
    _selectedModelPath = modelPath;
    _errorMessage = '';
    _modelType = ModelType.local;
    await _settingsRepository.saveModelTypePreference(ModelType.local);
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

  Future<bool> switchToOpenAI() async {
    _modelType = ModelType.openAi;
    _state = ChatState.loading;
    _errorMessage = '';
    await _settingsRepository.saveModelTypePreference(ModelType.openAi);
    notifyListeners();

    await _initializeOpenAI();

    return _state == ChatState.ready;
  }

  Future<void> switchToLocalModel() async {
    _modelType = ModelType.local;
    _state =
        ChatState.initial; // Reset to initial to prompt for model selection
    await _settingsRepository.saveModelTypePreference(ModelType.local);

    // Clear messages when switching model types
    _messages.clear();

    notifyListeners();
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
      if (_modelType == ModelType.local) {
        await _modelService.sendPrompt(content);
      } else {
        await _openAIService.sendPrompt(content, _messages);
      }
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

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _modelService.dispose();
    _openAIService.dispose();
    super.dispose();
  }
}
