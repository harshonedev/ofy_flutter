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
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(GetSettingsEvent());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
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
            if (state.apiKey != null && _apiKeyController.text.isEmpty) {
              _apiKeyController.text = state.apiKey!;
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OpenAI Settings
                  if (state.modelType == ModelType.openAi)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      child: Card(
                        key: const ValueKey('openai_settings'),
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
                                    Icons.api_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppConstants.openAiSettingsTitle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _apiKeyController,
                                decoration: InputDecoration(
                                  labelText: 'API Key',
                                  hintText: AppConstants.apiKeyHint,
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
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    if (_apiKeyController.text.isNotEmpty) {
                                      context.read<SettingsBloc>().add(
                                        SaveApiKeyEvent(
                                          apiKey: _apiKeyController.text,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppConstants.apiKeyErrorMessage,
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onErrorContainer,
                                            ),
                                          ),
                                          backgroundColor:
                                              colorScheme.errorContainer,
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(12),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.save_rounded),
                                  label: const Text(
                                    AppConstants.saveButtonText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
