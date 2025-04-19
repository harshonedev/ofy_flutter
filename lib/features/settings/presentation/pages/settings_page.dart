import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/core/constants/model_type.dart';
import 'package:llm_cpp_chat_app/features/chat/presentation/bloc/chat_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../controllers/settings_controller.dart';
import '../widgets/local_model_settings_card.dart';
import '../widgets/model_settings_card.dart';
import '../widgets/model_type_selection_card.dart';
import '../widgets/settings_error_display.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
          // Update controllers with values from state
          _controller.updateControllersFromState(state);

          // Show success message if settings were saved
          if (state is SettingsLoaded && state.saveSuccess == true) {
            _showSuccessMessage(context, colorScheme);
          }
          if (state is SettingsLoaded) {
            context.read<ChatBloc>().add(
              SwitchModelTypeEvent(
                modelType: state.modelType,
                modelApiKey: state.getApiKey(state.modelType),
                modelName: state.getModelName(state.modelType),
              ),
            );
          }
          if (state is SettingsError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: SettingsErrorDisplay(
                  message: state.message,
                  colorScheme: colorScheme,
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: colorScheme.errorContainer,
                margin: const EdgeInsets.all(12),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoaded) {
            return _buildSettingsContent(context, state, colorScheme);
          } else {
            return _buildSettingsContent(
              context,
              SettingsLoaded.empty(),
              colorScheme,
            );
          }
        },
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    SettingsLoaded state,
    ColorScheme colorScheme,
  ) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          // Model Type Selection Card
          ModelTypeSelectionCard(
            colorScheme: colorScheme,
            selectedModelType: state.modelType,
          ),

          const SizedBox(height: 24),

          // Model-specific Settings
          _buildModelSpecificSettings(state, colorScheme),
        ],
      ),
    );
  }

  Widget _buildModelSpecificSettings(
    SettingsLoaded state,
    ColorScheme colorScheme,
  ) {
    switch (state.modelType) {
      case ModelType.local:
        return LocalModelSettingsCard(colorScheme: colorScheme);

      case ModelType.openAi:
        return ModelSettingsCard(
          title: AppConstants.openAiSettingsTitle,
          icon: Icons.api_rounded,
          modelType: ModelType.openAi,
          showModelName: true,
          apiKeyHint: AppConstants.apiKeyHint,
          colorScheme: colorScheme,
          apiKeyController: _controller.apiKeyControllers[ModelType.openAi]!,
          modelNameController:
              _controller.modelNameControllers[ModelType.openAi]!,
        );

      case ModelType.claude:
        return ModelSettingsCard(
          title: AppConstants.claudeSettingsTitle,
          icon: Icons.psychology_alt_outlined,
          modelType: ModelType.claude,
          showModelName: true,
          apiKeyHint: 'Enter your Claude API key',
          modelNameHint: 'e.g., claude-3-opus-20240229',
          colorScheme: colorScheme,
          apiKeyController: _controller.apiKeyControllers[ModelType.claude]!,
          modelNameController:
              _controller.modelNameControllers[ModelType.claude]!,
        );

      case ModelType.ai4Chat:
        return ModelSettingsCard(
          title: AppConstants.ai4ChatSettingsTitle,
          icon: Icons.chat_outlined,
          modelType: ModelType.ai4Chat,
          showModelName: true,
          apiKeyHint: 'Enter your AI4Chat API key',
          modelNameHint: 'e.g., gpt-4, llama-3, or claude-opus',
          colorScheme: colorScheme,
          apiKeyController: _controller.apiKeyControllers[ModelType.ai4Chat]!,
          modelNameController:
              _controller.modelNameControllers[ModelType.ai4Chat]!,
        );
    }
  }

  void _showSuccessMessage(BuildContext context, ColorScheme colorScheme) {
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
            Text(
              AppConstants.apiKeySavedMessage,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.secondaryContainer,
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}
