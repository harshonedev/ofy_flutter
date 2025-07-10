class AppConstants {
  // App Info
  static const String appName = 'OfflineAI';
  static const String appVersion = '1.0.0';

  // Model Files
  static const List<String> supportedModelExtensions = ['gguf'];

  // Chat Messages
  static const String welcomeMessage =
      'Welcome to OfflineAI! You can chat with a local model or use OpenAI.';
  static const String modelLoadingMessage = 'Loading model, please wait...';
  static const String modelLoadingErrorMessage =
      'Failed to load model. Please try again with a different model file.';

  // UI Text
  static const String pickModelButtonText =
      'Select Model File from Local Storage';
  static const String chatScreenTitle = 'Chat with LLM';
  static const String messageHint = 'Type your message...';
  static const String sendButtonText = 'Send';
  static const String selectFromDownloadButtonText = 'Download Models';

  //BASE URL of the API
  static const String openAiBaseUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String ai4ChatBaseUrl =
      'https://app.ai4chat.co/api/v1/chat/completions';
  static const String claudeaiBaseUrl = 'https://api.anthropic.com/v1/messages';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String openAiSettingsTitle = 'OpenAI Settings';
  static const String localModelSettingsTitle = 'Local Model Settings';
  static const String apiKeyHint = 'Enter your OpenAI API key';
  static const String saveButtonText = 'Save';
  static const String apiKeySavedMessage =
      'Model credentials saved successfully';
  static const String apiKeyErrorMessage = 'Please enter a valid API key';

  // Model Selection
  static const String modelSelectionTitle = 'Select Model Type';
  static const String localModelLabel = 'Local Model';
  static const String openAiModelLabel = 'OpenAI';
  static const String claudeModelLabel = 'Claude AI';
  static const String ai4ChatModelLabel = 'AI4Chat';
  static const String customModelLabel = 'Custom API';
  static const String openAiApiKeyMissing =
      'Please set your OpenAI API key in settings first';
  static const String claudeApiKeyMissing =
      'Please set your Claude API key in settings first';
  static const String ai4ChatApiKeyMissing =
      'Please set your AI4Chat API key in settings first';

  // Model Settings
  static const String ai4ChatSettingsTitle = 'AI4Chat Settings';
  static const String claudeSettingsTitle = 'Claude AI Settings';
  static const String customSettingsTitle = 'Custom API Settings';
  static const String modelNameLabel = 'Model Name';
  static const String modelNameHint = 'Enter model name';
  static const String apiKeyLabel = 'API Key';

  // Download Manager
  static const String defaultDownloadPath = '/storage/emulated/0/Download';
}
