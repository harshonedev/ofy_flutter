import 'package:equatable/equatable.dart';

class ModelFile extends Equatable {
  final String fileName;
  final String filePath;
  final String fileSize;
  final String taskId;

  const ModelFile({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.taskId,
  });

  // Factory constructor for creating from JSON or Map
  factory ModelFile.fromMap(Map<String, dynamic> map) {
    return ModelFile(
      fileName: map['fileName'] ?? '',
      filePath: map['filePath'] ?? '',
      fileSize: map['fileSize'] ?? '',
      taskId: map['taskId'] ?? '',
    );
  }

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'taskId': taskId,
    };
  }

  // Helper methods
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.isNotEmpty ? parts.last : '';
  }

  bool get isGGUFModel => fileExtension.toLowerCase() == 'gguf';

  // Copy with method for immutability
  ModelFile copyWith({
    String? fileName,
    String? filePath,
    String? fileSize,
    String? taskId,
  }) {
    return ModelFile(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  List<Object> get props => [fileName, filePath, fileSize, taskId];

  @override
  String toString() {
    return 'ModelFile(fileName: $fileName, fileSize: $fileSize, taskId: $taskId)';
  }
}
