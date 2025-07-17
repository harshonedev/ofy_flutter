import 'package:background_downloader/background_downloader.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';

class DownloadModelData extends DownloadModel {
  const DownloadModelData({
    required super.task,
    required super.fileName,
    required super.filePath,
    super.progress,
    super.status,
    super.expectedFileSize,
    super.networkSpeed,
    super.timeRemaining,
    super.isPaused = false,
  });

  factory DownloadModelData.fromTask(Task task) {
    return DownloadModelData(
      task: task,
      fileName: task.filename,
      filePath: task.baseDirectory.name,
    );
  }

  @override
  DownloadModelData copyWith({
    Task? task,
    String? fileName,
    String? filePath,
    int? progress,
    String? status,
    String? expectedFileSize,
    String? networkSpeed,
    String? timeRemaining,
    bool? isPaused, 
  }) {
    return DownloadModelData(
      task: task ?? this.task,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      expectedFileSize: expectedFileSize ?? this.expectedFileSize,
      networkSpeed: networkSpeed ?? this.networkSpeed,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
