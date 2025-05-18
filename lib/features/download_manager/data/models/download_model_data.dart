
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';

class DownloadModelData extends DownloadModel {

  const DownloadModelData({
    required super.fileName,
    required super.fileUrl,
    required super.taskId,
    required super.progress,
    required super.isPaused, 
    required super.status,
  });

  factory DownloadModelData.fromDownloadTask(DownloadTask downloadTask) {
    return DownloadModelData(
    fileName: downloadTask.filename ?? 'Unknown',
      fileUrl: downloadTask.url,
      taskId: downloadTask.taskId,
      progress: downloadTask.progress,
      isPaused: downloadTask.status == DownloadTaskStatus.paused,
      status: downloadTask.status.name,
    );
  }

}