// filepath: /home/harsh/FlutterProjects/llm_cpp_chat_app-1/lib/features/settings/data/repositories/settings_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/model_type.dart';

class SettingsRepository {
  static const String _apiKeyKey = 'openai_api_key';
  static const String _openAiModelKey = 'openai_model';
  static const String _modelTypeKey = 'model_type';

  // Get OpenAI API key
  Future<String?> getOpenAiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // Save OpenAI API key
  Future<void> saveOpenAiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  // Get selected OpenAI model name (e.g. "gpt-4", "gpt-3.5-turbo")
  Future<String> getOpenAiModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openAiModelKey) ?? 'gpt-3.5-turbo';
  }

  // Save selected OpenAI model
  Future<void> saveOpenAiModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_openAiModelKey, model);
  }

  // Get model type preference (local or OpenAI)
  Future<ModelType> getModelTypePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_modelTypeKey);

    if (value == null) return ModelType.local; // Default to local

    return ModelType.values.firstWhere(
      (type) => type.toString() == value,
      orElse: () => ModelType.local,
    );
  }

  // Save model type preference
  Future<void> saveModelTypePreference(ModelType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelTypeKey, type.toString());
  }
}
