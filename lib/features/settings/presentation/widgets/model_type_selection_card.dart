import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/model_type.dart';
import 'model_type_option.dart';

class ModelTypeSelectionCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final ModelType selectedModelType;

  const ModelTypeSelectionCard({
    super.key,
    required this.colorScheme,
    required this.selectedModelType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            _buildModelTypeOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.model_training_rounded, color: colorScheme.primary),
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
    );
  }

  Widget _buildModelTypeOptions(BuildContext context) {
    return Column(
      children: [
        ModelTypeOption(
          title: AppConstants.localModelLabel,
          subtitle: 'Run inference completely on-device',
          icon: Icons.computer_rounded,
          value: ModelType.local,
          groupValue: selectedModelType,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 8),
        ModelTypeOption(
          title: AppConstants.openAiModelLabel,
          subtitle: 'Use OpenAI\'s API for chat completions',
          icon: Icons.cloud_outlined,
          value: ModelType.openAi,
          groupValue: selectedModelType,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 8),
        ModelTypeOption(
          title: AppConstants.claudeModelLabel,
          subtitle: 'Use Anthropic\'s Claude API',
          icon: Icons.psychology_alt_outlined,
          value: ModelType.claude,
          groupValue: selectedModelType,
          colorScheme: colorScheme,
        ),
        
      ],
    );
  }
}
