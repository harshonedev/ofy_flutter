import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/exceptions.dart';

abstract class SettingsLocalDataSource {
  /// Gets the cached ModelType or returns [ModelType.local] as default
  Future<ModelType> getModelTypePreference();

  /// Caches the ModelType for later use
  Future<bool> saveModelTypePreference(ModelType modelType);

  /// Gets the cached API key for a specific model type
  Future<String?> getApiKey(ModelType modelType);

  /// Caches the API key for a specific model type
  Future<bool> saveApiKey(String apiKey, ModelType modelType);

  /// Gets the cached model name for a specific model type
  Future<String?> getModelName(ModelType modelType);

  /// Caches the model name for a specific model type
  Future<bool> saveModelName(String modelName, ModelType modelType);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  static const _modelTypeKey = 'MODEL_TYPE_KEY';
  static const _apiKeyKey = 'API_KEY';
  static const _modelNameKey = 'MODEL_NAME';

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
  Future<String?> getApiKey(ModelType modelType) async {
    try {
      return sharedPreferences.getString(
        _apiKeyKey + _modelTypeToString(modelType),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to load API key');
    }
  }

  @override
  Future<bool> saveApiKey(String apiKey, ModelType modelType) async {
    try {
      return await sharedPreferences.setString(
        _apiKeyKey + _modelTypeToString(modelType),
        apiKey,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save API key');
    }
  }

  @override
  Future<String?> getModelName(ModelType modelType) async {
    try {
      return sharedPreferences.getString(
        _modelNameKey + _modelTypeToString(modelType),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to load model name');
    }
  }

  @override
  Future<bool> saveModelName(String modelName, ModelType modelType) async {
    try {
      return await sharedPreferences.setString(
        _modelNameKey + _modelTypeToString(modelType),
        modelName,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save model name');
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
      default:
        return ModelType.local;
    }
  }
}
