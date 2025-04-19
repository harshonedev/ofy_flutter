import 'package:flutter/material.dart';
import '../../../../core/constants/model_type.dart';

class ChatAppBarActions extends StatelessWidget {
  final ModelType modelType;
  final ColorScheme colorScheme;
  final VoidCallback onSelectLocalModel;
  final VoidCallback onChangeLocalModel;
  final VoidCallback onOpenSettings;
  final VoidCallback onClearChat;

  const ChatAppBarActions({
    super.key,
    required this.modelType,
    required this.colorScheme,
    required this.onSelectLocalModel,
    required this.onChangeLocalModel,
    required this.onOpenSettings,
    required this.onClearChat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (modelType == ModelType.local)
          IconButton(
            icon: const Icon(Icons.folder_open_rounded),
            tooltip: 'Configure Local Model',
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.all(10),
            ),
            onPressed: onChangeLocalModel,
          ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Settings',
          style: IconButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.all(10),
          ),
          onPressed: onOpenSettings,
        ),
        _buildOptionsMenu(context, colorScheme, modelType),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildOptionsMenu(
    BuildContext context,
    ColorScheme colorScheme,
    ModelType modelType,
  ) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert_rounded),
      position: PopupMenuPosition.under,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder:
          (context) => [
            if (modelType == ModelType.openAi)
              PopupMenuItem(
                value: 'switchToLocal',
                child: _buildMenuItem(
                  icon: Icons.computer_rounded,
                  text: 'Switch to Local Model',
                  colorScheme: colorScheme,
                ),
              ),
            PopupMenuItem(
              value: 'clearChat',
              child: _buildMenuItem(
                icon: Icons.cleaning_services_rounded,
                text: 'Clear Chat',
                colorScheme: colorScheme,
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'switchToLocal':
            onSelectLocalModel();
            break;
          case 'clearChat':
            onClearChat();
            break;
        }
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
