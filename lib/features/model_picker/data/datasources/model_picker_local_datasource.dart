import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

abstract class ModelPickerLocalDataSource {
  /// Gets the cached model path
  Future<String?> getModelPath();

  /// Caches the model path for later use
  Future<bool> saveModelPath(String modelPath);
}

class ModelPickerLocalDataSourceImpl implements ModelPickerLocalDataSource {
  final SharedPreferences sharedPreferences;

  ModelPickerLocalDataSourceImpl({required this.sharedPreferences});

  static const _modelPathKey = 'MODEL_PATH_KEY';

  @override
  Future<String?> getModelPath() async {
    try {
      return sharedPreferences.getString(_modelPathKey);
    } catch (e) {
      throw CacheException(message: 'Failed to load model path');
    }
  }

  @override
  Future<bool> saveModelPath(String modelPath) async {
    try {
      return await sharedPreferences.setString(_modelPathKey, modelPath);
    } catch (e) {
      throw CacheException(message: 'Failed to save model path');
    }
  }
}
