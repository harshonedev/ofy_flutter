class AppConstants {
  // App Info
  static const String appName = 'LLM Chat App';
  static const String appVersion = '1.0.0';

  // Model Files
  static const List<String> supportedModelExtensions = ['gguf'];

  // Chat Messages
  static const String welcomeMessage =
      'Welcome to LLM Chat App! Please select a model file to start chatting.';
  static const String modelLoadingMessage = 'Loading model, please wait...';
  static const String modelLoadingErrorMessage =
      'Failed to load model. Please try again with a different model file.';

  // UI Text
  static const String pickModelButtonText = 'Select Model File';
  static const String chatScreenTitle = 'Chat with LLM';
  static const String messageHint = 'Type your message...';
  static const String sendButtonText = 'Send';
}
