import 'package:flutter/material.dart';
import '../../../../core/utils/model_utils.dart';

class ModelCard extends StatelessWidget {
  final String modelPath;
  final bool isSelected;
  final VoidCallback onTap;

  const ModelCard({
    required this.modelPath,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final modelInfo = ModelUtils.getModelInfo(modelPath);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.model_training, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      modelInfo['name'] ?? 'Unknown Model',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Size',
                modelInfo['size'] ?? 'Unknown',
                Icons.data_usage,
              ),
              _buildInfoRow(
                context,
                'Type',
                modelInfo['type'] ?? 'Unknown',
                Icons.category,
              ),
              _buildInfoRow(
                context,
                'Quantization',
                modelInfo['quantization'] ?? 'Unknown',
                Icons.memory,
              ),
              _buildInfoRow(
                context,
                'Last Used',
                modelInfo['lastModified'] ?? 'Unknown',
                Icons.access_time,
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${ModelUtils.getModelNameFromPath(modelPath)}',
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
