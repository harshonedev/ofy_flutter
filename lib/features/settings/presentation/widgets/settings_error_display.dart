import 'package:flutter/material.dart';

class SettingsErrorDisplay extends StatelessWidget {
  final String message;
  final ColorScheme colorScheme;

  const SettingsErrorDisplay({
    super.key,
    required this.message,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colorScheme.error),
          const SizedBox(width: 12),
          Text('Error: $message', style: TextStyle(color: colorScheme.onError)),
        ],
      ),
    );
  }
}
