import 'package:equatable/equatable.dart';

class DownloadModel extends Equatable {
  final String taskId;
  final String fileName;
  final String fileUrl;
  final int progress;
  final bool isPaused;
  final String status;

  const DownloadModel({
    required this.taskId,
    required this.fileName,
    required this.fileUrl,
    required this.progress,
    required this.isPaused,
    required this.status,
  });

  DownloadModel copyWith({
    String? taskId,
    String? fileName,
    String? fileUrl,
    int? progress,
    bool? isPaused,
    String? status,
  }) {
    return DownloadModel(
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      progress: progress ?? this.progress,
      isPaused: isPaused ?? this.isPaused,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [taskId, fileName, fileUrl, progress, isPaused, status];
}