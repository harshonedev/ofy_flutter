import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  final String fileName;
  final VoidCallback onPressed;

  const DownloadButton({
    Key? key,
    required this.fileName,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.download),
      label: const Text('Download'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
