import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';

class LocalModelSettingsCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const LocalModelSettingsCard({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      child: Card(
        key: const ValueKey('local_model_settings'),
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
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.settings_rounded, color: colorScheme.primary),
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
    );
  }

  Widget _buildInfoSection() {
    return Row(
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
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
