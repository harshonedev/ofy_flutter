import 'dart:async';
import 'package:background_downloader/background_downloader.dart';
import 'package:llm_cpp_chat_app/core/utils/model_utils.dart';
import 'package:logger/logger.dart';

class DownloadService {
  final Logger logger = Logger();
  final FileDownloader downloader;

  final StreamController<DownloadProgress> _downloadProgressStreamController =
      StreamController<DownloadProgress>.broadcast();
  final StreamController<DownloadStatus> _downloadStatusStreamController =
      StreamController<DownloadStatus>.broadcast();

  Stream<DownloadProgress> get downloadProgressStream =>
      _downloadProgressStreamController.stream;
  Stream<DownloadStatus> get downloadStatusStream =>
      _downloadStatusStreamController.stream;

  DownloadService({required this.downloader});

  Future<Task?> downloadFile(String fileUrl, String fileName) async {
    try {
      final task = DownloadTask(
        url: fileUrl,
        filename: fileName,
        retries: 3,
        directory: 'models',
        allowPause: true,
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
      );
      final successfullyEnqueued = await downloader.enqueue(task);
      logger.i('Download started: $successfullyEnqueued');
      return successfullyEnqueued ? task : null;
    } catch (e) {
      logger.e('Error downloading file: $e');
      throw Exception('Failed to download file');
    }
  }

  void startDownloader() {
    downloader.start();
    logger.i('Downloader started');
  }

  void startListeningToDownloads() {
    downloader.updates.listen(
      (update) {
        switch (update) {
          case TaskStatusUpdate():
            _downloadStatusStreamController.add(
              DownloadStatus(task: update.task, status: update.status),
            );
            logger.i('Download status updated: ${update.status}');

          case TaskProgressUpdate():
            _downloadProgressStreamController.add(
              DownloadProgress(
                task: update.task,
                progress: update.progress,
                expectedFileSize: ModelUtils.calculateFileSize(
                  update.expectedFileSize,
                ),
                networkSpeed: update.networkSpeedAsString,
                timeRemaining: update.timeRemainingAsString,
              ),
            );
            logger.i(
              'Download progress updated: ${update.progress}%, '
              'Expected Size: ${update.expectedFileSize}, '
              'Network Speed: ${update.networkSpeedAsString}, '
              'Time Remaining: ${update.timeRemainingAsString}',
            );
        }
      },
      onError: (error) {
        logger.e('Error in download updates stream: $error');
      },
    );
  }

  Future<List<TaskRecord>> loadDownlaods() async {
    try {
      final taskRecords = await downloader.database.allRecords();
      if (taskRecords.isNotEmpty) {
        for (var record in taskRecords) {
          logger.i(
            'Task ID: ${record.taskId}, Status: ${record.status}, Progress: ${record.progress}, File Name: ${record.task.filename}, Dir: ${record.task.directory}, baseDir : ${record.task.baseDirectory.name}',
          );
        }
      }
      return taskRecords;
    } catch (e) {
      logger.e('Error loading downloads: $e');
      throw Exception('Failed to load downloads');
    }
  }

  Future<bool> cancelDownload(Task task) async {
    return await downloader.cancelTaskWithId(task.taskId);
  }

  Future<bool> pauseDownload(DownloadTask task) async {
    return await downloader.pause(task);
  }

  Future<bool> resumeDownload(DownloadTask task) async {
    return await downloader.resume(task);
  }

  Future<void> deleteDownload(String taskId) async {
    await downloader.database.deleteRecordWithId(taskId);
  }

  void dispose() {
    _downloadProgressStreamController.close();
    _downloadStatusStreamController.close();
    logger.i('DownloadService disposed');
  }
}

class DownloadProgress {
  final Task task;
  final double progress;
  final String expectedFileSize;
  final String networkSpeed;
  final String timeRemaining;

  const DownloadProgress({
    required this.task,
    required this.progress,
    required this.expectedFileSize,
    required this.networkSpeed,
    required this.timeRemaining,
  });
}

class DownloadStatus {
  final Task task;
  final TaskStatus status;

  const DownloadStatus({required this.task, required this.status});
}
