import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  final String fileName;
  final VoidCallback onPressed;

  const DownloadButton({
    super.key,
    required this.fileName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton.filled(
      onPressed: onPressed,
      icon: const Icon(Icons.download_rounded),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
    );
  }
}
