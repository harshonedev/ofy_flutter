import 'package:flutter/material.dart';

import '../../../../../core/constants/model_type.dart';
import '../bloc/settings_state.dart';

class SettingsController {
  final Map<ModelType, TextEditingController> apiKeyControllers = {};
  final Map<ModelType, TextEditingController> modelNameControllers = {};

  SettingsController() {
    // Initialize controllers for each model type
    for (var modelType in ModelType.values) {
      apiKeyControllers[modelType] = TextEditingController();
      modelNameControllers[modelType] = TextEditingController();
    }
  }

  void updateControllersFromState(SettingsState state) {
    if (state is SettingsLoaded) {
      for (var modelType in ModelType.values) {
        final apiKey = state.getApiKey(modelType);
        if (apiKey != null && apiKeyControllers[modelType]!.text.isEmpty) {
          apiKeyControllers[modelType]!.text = apiKey;
        }

        final modelName = state.getModelName(modelType);
        if (modelName != null &&
            modelNameControllers[modelType]!.text.isEmpty) {
          modelNameControllers[modelType]!.text = modelName;
        }
      }
    }
  }

  void dispose() {
    for (var controller in apiKeyControllers.values) {
      controller.dispose();
    }
    for (var controller in modelNameControllers.values) {
      controller.dispose();
    }
  }
}
