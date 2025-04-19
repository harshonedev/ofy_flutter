import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_type.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<ModelType, TextEditingController> _apiKeyControllers = {};
  final Map<ModelType, TextEditingController> _modelNameControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each model type
    for (var modelType in ModelType.values) {
      _apiKeyControllers[modelType] = TextEditingController();
      _modelNameControllers[modelType] = TextEditingController();
    }

    context.read<SettingsBloc>().add(GetSettingsEvent());
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _apiKeyControllers.values) {
      controller.dispose();
    }
    for (var controller in _modelNameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.settingsTitle),
        centerTitle: false,
        scrolledUnderElevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            // Update controllers with values from state
            for (var modelType in ModelType.values) {
              final apiKey = state.getApiKey(modelType);
              if (apiKey != null &&
                  _apiKeyControllers[modelType]!.text.isEmpty) {
                _apiKeyControllers[modelType]!.text = apiKey;
              }

              final modelName = state.getModelName(modelType);
              if (modelName != null &&
                  _modelNameControllers[modelType]!.text.isEmpty) {
                _modelNameControllers[modelType]!.text = modelName;
              }
            }

            if (state.saveSuccess == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: colorScheme.onSurface,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      const Text(AppConstants.apiKeySavedMessage),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.secondaryContainer,
                  margin: const EdgeInsets.all(12),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is SettingsInitial || state is SettingsLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: colorScheme.error, fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (state is SettingsLoaded) {
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                children: [
                  // Model Type Selection Section
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.model_training_rounded,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppConstants.modelSelectionTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildModelTypeOption(
                            context,
                            colorScheme,
                            title: AppConstants.localModelLabel,
                            subtitle: 'Run inference completely on-device',
                            icon: Icons.computer_rounded,
                            value: ModelType.local,
                            groupValue: state.modelType,
                          ),
                          const SizedBox(height: 8),
                          _buildModelTypeOption(
                            context,
                            colorScheme,
                            title: AppConstants.openAiModelLabel,
                            subtitle: 'Use OpenAI\'s API for chat completions',
                            icon: Icons.cloud_outlined,
                            value: ModelType.openAi,
                            groupValue: state.modelType,
                          ),
                          const SizedBox(height: 8),
                          _buildModelTypeOption(
                            context,
                            colorScheme,
                            title: AppConstants.claudeModelLabel,
                            subtitle: 'Use Anthropic\'s Claude API',
                            icon: Icons.psychology_alt_outlined,
                            value: ModelType.claude,
                            groupValue: state.modelType,
                          ),
                          const SizedBox(height: 8),
                          _buildModelTypeOption(
                            context,
                            colorScheme,
                            title: AppConstants.ai4ChatModelLabel,
                            subtitle: 'Use AI4Chat API for cloud inference',
                            icon: Icons.chat_outlined,
                            value: ModelType.ai4Chat,
                            groupValue: state.modelType,
                          ),
                          const SizedBox(height: 8),
                          _buildModelTypeOption(
                            context,
                            colorScheme,
                            title: AppConstants.customModelLabel,
                            subtitle: 'Configure a custom LLM API endpoint',
                            icon: Icons.settings_suggest_outlined,
                            value: ModelType.custom,
                            groupValue: state.modelType,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Model-specific Settings
                  if (state.modelType == ModelType.openAi)
                    _buildModelSettings(
                      context,
                      colorScheme,
                      state,
                      title: AppConstants.openAiSettingsTitle,
                      icon: Icons.api_rounded,
                      modelType: ModelType.openAi,
                      showModelName: false,
                      apiKeyHint: AppConstants.apiKeyHint,
                    ),

                  if (state.modelType == ModelType.claude)
                    _buildModelSettings(
                      context,
                      colorScheme,
                      state,
                      title: AppConstants.claudeSettingsTitle,
                      icon: Icons.psychology_alt_outlined,
                      modelType: ModelType.claude,
                      showModelName: true,
                      apiKeyHint: 'Enter your Claude API key',
                      modelNameHint: 'e.g., claude-3-opus-20240229',
                    ),

                  if (state.modelType == ModelType.ai4Chat)
                    _buildModelSettings(
                      context,
                      colorScheme,
                      state,
                      title: AppConstants.ai4ChatSettingsTitle,
                      icon: Icons.chat_outlined,
                      modelType: ModelType.ai4Chat,
                      showModelName: true,
                      apiKeyHint: 'Enter your AI4Chat API key',
                      modelNameHint: 'e.g., gpt-4, llama-3, or claude-opus',
                    ),

                  if (state.modelType == ModelType.custom)
                    _buildModelSettings(
                      context,
                      colorScheme,
                      state,
                      title: AppConstants.customSettingsTitle,
                      icon: Icons.settings_suggest_outlined,
                      modelType: ModelType.custom,
                      showModelName: true,
                      apiKeyHint: 'Enter API key for custom endpoint',
                      modelNameHint: 'Enter model identifier',
                    ),

                  // Local Model Settings
                  if (state.modelType == ModelType.local)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      child: Card(
                        key: const ValueKey('local_model_settings'),
                        elevation: 0,
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.settings_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppConstants.localModelSettingsTitle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 20,
                                    color: colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Local model settings will be configured when you select a model file.',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'Unknown state',
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildModelSettings(
    BuildContext context,
    ColorScheme colorScheme,
    SettingsLoaded state, {
    required String title,
    required IconData icon,
    required ModelType modelType,
    required bool showModelName,
    required String apiKeyHint,
    String? modelNameHint,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      child: Card(
        key: ValueKey('${modelType.toString()}_settings'),
        elevation: 0,
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // API Key field
              TextField(
                controller: _apiKeyControllers[modelType],
                decoration: InputDecoration(
                  labelText: AppConstants.apiKeyLabel,
                  hintText: apiKeyHint,
                  prefixIcon: Icon(
                    Icons.key_rounded,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                style: TextStyle(color: colorScheme.onSurface),
              ),

              // Optional Model Name field
              if (showModelName) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _modelNameControllers[modelType],
                  decoration: InputDecoration(
                    labelText: AppConstants.modelNameLabel,
                    hintText: modelNameHint ?? AppConstants.modelNameHint,
                    prefixIcon: Icon(
                      Icons.label_outline_rounded,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {
                    final apiKey = _apiKeyControllers[modelType]!.text;
                    if (apiKey.isNotEmpty) {
                      // Save API Key
                      context.read<SettingsBloc>().add(
                        SaveApiKeyEvent(apiKey: apiKey, modelType: modelType),
                      );

                      // If model name is shown and not empty, save it too
                      if (showModelName &&
                          _modelNameControllers[modelType]!.text.isNotEmpty) {
                        context.read<SettingsBloc>().add(
                          SaveModelNameEvent(
                            modelName: _modelNameControllers[modelType]!.text,
                            modelType: modelType,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppConstants.apiKeyErrorMessage,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                          backgroundColor: colorScheme.errorContainer,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(12),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(AppConstants.saveButtonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelTypeOption(
    BuildContext context,
    ColorScheme colorScheme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ModelType value,
    required ModelType groupValue,
  }) {
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<SettingsBloc>().add(
            SaveModelTypeEvent(modelType: value),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: [
              Radio<ModelType>(
                value: value,
                groupValue: groupValue,
                activeColor: colorScheme.primary,
                onChanged: (ModelType? newValue) {
                  if (newValue != null) {
                    context.read<SettingsBloc>().add(
                      SaveModelTypeEvent(modelType: newValue),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
