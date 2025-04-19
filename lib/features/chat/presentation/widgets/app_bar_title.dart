import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_type.dart';

class AppBarTitle extends StatelessWidget {
  final ModelType modelType;
  final bool isReady;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const AppBarTitle({
    super.key,
    required this.modelType,
    required this.isReady,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Prevent row from taking max width
      children: [
        Flexible(
          // Allow title to shrink
          child: Text(
            AppConstants.chatScreenTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis, // Handle overflow
            maxLines: 1,
          ),
        ),
        // Add spacing before badges
        const SizedBox(width: 8),
        // Badges (conditionally shown)
        if (modelType == ModelType.local && isReady)
          _buildLocalModelBadge(colorScheme),
        if (modelType != ModelType.local)
          _buildRemoteModelBadge(colorScheme, modelType),
      ],
    );
  }

  Widget _buildRemoteModelBadge(ColorScheme colorScheme, ModelType modelType) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 11,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            modelType.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalModelBadge(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.memory_rounded,
            size: 11,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Local',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
