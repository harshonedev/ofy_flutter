import 'package:flutter/material.dart';

class SettingsLoadingIndicator extends StatelessWidget {
  final ColorScheme colorScheme;

  const SettingsLoadingIndicator({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: colorScheme.primary));
  }
}
