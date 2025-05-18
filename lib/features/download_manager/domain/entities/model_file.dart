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

  @override
  List<Object> get props => [fileName, filePath, fileSize, taskId];
}