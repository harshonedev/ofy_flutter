import 'dart:io';

class ModelUtils {
  /// Checks if a file is a valid GGUF model file
  static bool isValidModelFile(String filePath) {
    if (filePath.isEmpty) return false;

    final file = File(filePath);
    if (!file.existsSync()) return false;

    final extension = filePath.split('.').last.toLowerCase();
    return extension == 'gguf';
  }

  /// Gets the file size in MB
  static double getFileSizeInMB(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return 0;

    return file.lengthSync() / (1024 * 1024);
  }

  /// Gets the model name from file path
  static String getModelNameFromPath(String filePath) {
    if (filePath.isEmpty) return '';

    final fileName = filePath.split('/').last;
    return fileName;
  }

  /// Extracts basic model info from filename
  static Map<String, String> getModelInfo(String filePath) {
    final fileName = getModelNameFromPath(filePath);
    final fileSize = getFileSizeInMB(filePath).toStringAsFixed(1);

    // Try to extract information from common naming patterns
    String modelType = 'Unknown';
    String quantization = 'Unknown';

    if (fileName.contains('chat') || fileName.contains('instruct')) {
      modelType = 'Chat';
    } else if (fileName.contains('base')) {
      modelType = 'Base';
    }

    // Check for common quantization patterns
    if (fileName.contains('q2')) {
      quantization = '2-bit';
    } else if (fileName.contains('q3')) {
      quantization = '3-bit';
    } else if (fileName.contains('q4')) {
      quantization = '4-bit';
    } else if (fileName.contains('q5')) {
      quantization = '5-bit';
    } else if (fileName.contains('q6')) {
      quantization = '6-bit';
    } else if (fileName.contains('q8')) {
      quantization = '8-bit';
    } else if (fileName.contains('f16')) {
      quantization = '16-bit float';
    }

    return {
      'name': fileName,
      'size': '$fileSize MB',
      'type': modelType,
      'quantization': quantization,
      'lastModified': _getLastModifiedDate(filePath),
    };
  }

  static String calculateFileSize(int sizeInBytes) {
    // Convert bytes to KB, MB, GB, etc.
    if (sizeInBytes >= 1024 * 1024 * 1024) {
      final sizeInGB = sizeInBytes / (1024 * 1024 * 1024);
      return '${sizeInGB.toStringAsFixed(2)} GB';
    } else if (sizeInBytes >= 1024 * 1024) {
      final sizeInMB = sizeInBytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(2)} MB';
    } else if (sizeInBytes >= 1024) {
      final sizeInKB = sizeInBytes / 1024;     
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      return '$sizeInBytes bytes';
    }
  }

  /// Get last modified date for the file
  static String _getLastModifiedDate(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return 'Unknown';

      final lastModified = file.lastModifiedSync();
      return '${lastModified.day}/${lastModified.month}/${lastModified.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
