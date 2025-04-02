import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/model_utils.dart';

class ModelRepository {
  static const String _recentModelsKey = 'recent_models';

  // Get recent model paths
  Future<List<String>> getRecentModels() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentModelsKey) ?? [];
  }

  // Save a model path to recents
  Future<void> saveRecentModel(String modelPath) async {
    if (!ModelUtils.isValidModelFile(modelPath)) return;

    final prefs = await SharedPreferences.getInstance();
    final recentModels = prefs.getStringList(_recentModelsKey) ?? [];

    // Remove if already exists
    recentModels.remove(modelPath);

    // Add to beginning of list
    recentModels.insert(0, modelPath);

    // Keep only the most recent 5 models
    final updatedList = recentModels.take(5).toList();

    await prefs.setStringList(_recentModelsKey, updatedList);
  }

  // Check if model file exists and is valid
  Future<bool> validateModelFile(String path) async {
    if (path.isEmpty) return false;

    final file = File(path);
    if (!await file.exists()) return false;

    return ModelUtils.isValidModelFile(path);
  }
}
