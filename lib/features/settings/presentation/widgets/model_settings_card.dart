import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/model_type.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';

class ModelSettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ModelType modelType;
  final bool showModelName;
  final String apiKeyHint;
  final String? modelNameHint;
  final ColorScheme colorScheme;
  final TextEditingController apiKeyController;
  final TextEditingController modelNameController;

  const ModelSettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.modelType,
    required this.showModelName,
    required this.apiKeyHint,
    this.modelNameHint,
    required this.colorScheme,
    required this.apiKeyController,
    required this.modelNameController,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              const SizedBox(height: 16),
              _buildApiKeyField(),
              if (showModelName) ...[
                const SizedBox(height: 16),
                _buildModelNameField(),
              ],
              const SizedBox(height: 16),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildApiKeyField() {
    return TextField(
      controller: apiKeyController,
      decoration: InputDecoration(
        labelText: AppConstants.apiKeyLabel,
        hintText: apiKeyHint,
        prefixIcon: Icon(Icons.key_rounded, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: true,
      style: TextStyle(color: colorScheme.onSurface),
    );
  }

  Widget _buildModelNameField() {
    return TextField(
      controller: modelNameController,
      decoration: InputDecoration(
        labelText: AppConstants.modelNameLabel,
        hintText: modelNameHint ?? AppConstants.modelNameHint,
        prefixIcon: Icon(
          Icons.label_outline_rounded,
          color: colorScheme.primary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: TextStyle(color: colorScheme.onSurface),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        onPressed: () => _saveSettings(context),
        icon: const Icon(Icons.save_rounded),
        label: const Text(AppConstants.saveButtonText),
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    final apiKey = apiKeyController.text;
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppConstants.apiKeyErrorMessage,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
        ),
      );
      return;
    }

    // Save API Key
    context.read<SettingsBloc>().add(
      SaveApiKeyEvent(apiKey: apiKey, modelType: modelType),
    );

    // If model name is shown and not empty, save it too
    if (showModelName && modelNameController.text.isNotEmpty) {
      context.read<SettingsBloc>().add(
        SaveModelNameEvent(
          modelName: modelNameController.text,
          modelType: modelType,
        ),
      );
    }
  }
}
