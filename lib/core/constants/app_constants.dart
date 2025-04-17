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
  static const String pickModelButtonText = 'Select Model File';
  static const String chatScreenTitle = 'Chat with LLM';
  static const String messageHint = 'Type your message...';
  static const String sendButtonText = 'Send';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String openAiSettingsTitle = 'OpenAI Settings';
  static const String localModelSettingsTitle = 'Local Model Settings';
  static const String apiKeyHint = 'Enter your OpenAI API key';
  static const String saveButtonText = 'Save';
  static const String apiKeySavedMessage = 'API key saved successfully';
  static const String apiKeyErrorMessage = 'Please enter a valid API key';

  // Model Selection
  static const String modelSelectionTitle = 'Select Model Type';
  static const String localModelLabel = 'Local Model';
  static const String openAiModelLabel = 'OpenAI';
  static const String openAiApiKeyMissing =
      'Please set your OpenAI API key in settings first';
}
