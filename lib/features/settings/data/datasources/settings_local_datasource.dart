import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/exceptions.dart';

abstract class SettingsLocalDataSource {
  /// Gets the cached ModelType or returns [ModelType.local] as default
  Future<ModelType> getModelTypePreference();

  /// Caches the ModelType for later use
  Future<bool> saveModelTypePreference(ModelType modelType);

  /// Gets the cached API key if any
  Future<String?> getApiKey();

  /// Caches the API key for later use
  Future<bool> saveApiKey(String apiKey);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  static const _modelTypeKey = 'MODEL_TYPE_KEY';
  static const _apiKeyKey = 'API_KEY';

  @override
  Future<ModelType> getModelTypePreference() async {
    try {
      final modelTypeString = sharedPreferences.getString(_modelTypeKey);
      if (modelTypeString == null) {
        return ModelType.local;
      }
      return _stringToModelType(modelTypeString);
    } catch (e) {
      throw CacheException(message: 'Failed to load model type preference');
    }
  }

  @override
  Future<bool> saveModelTypePreference(ModelType modelType) async {
    try {
      return await sharedPreferences.setString(
        _modelTypeKey,
        _modelTypeToString(modelType),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save model type preference');
    }
  }

  @override
  Future<String?> getApiKey() async {
    try {
      return sharedPreferences.getString(_apiKeyKey);
    } catch (e) {
      throw CacheException(message: 'Failed to load API key');
    }
  }

  @override
  Future<bool> saveApiKey(String apiKey) async {
    try {
      return await sharedPreferences.setString(_apiKeyKey, apiKey);
    } catch (e) {
      throw CacheException(message: 'Failed to save API key');
    }
  }

  String _modelTypeToString(ModelType modelType) {
    switch (modelType) {
      case ModelType.local:
        return 'local';
      case ModelType.openAi:
        return 'openai';
      case ModelType.claude:
        return 'claude';
      case ModelType.ai4chat:
        return 'ai4chat';
      case ModelType.custom:
        return 'custom';
      }
  }

  ModelType _stringToModelType(String modelTypeString) {
    switch (modelTypeString) {
      case 'local':
        return ModelType.local;
      case 'openai':
        return ModelType.openAi;
      case 'claude':
        return ModelType.claude;
      case 'ai4chat':
        return ModelType.ai4chat;
      case 'custom':
        return ModelType.custom;
      default:
        return ModelType.local;
    }
  }
}
