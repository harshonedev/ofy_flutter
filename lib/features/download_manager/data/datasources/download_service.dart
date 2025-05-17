import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:llm_cpp_chat_app/core/constants/app_constants.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadService {
  final Logger logger = Logger();
  final SharedPreferences sharedPreferences;

  final StreamController<int> _downloadProgressController =
      StreamController<int>.broadcast();
  Stream<int> get downloadProgressStream => _downloadProgressController.stream;

  DownloadService({required this.sharedPreferences});

  Future<String?> downloadFile(String fileUrl, String fileName) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: AppConstants.defaultDownloadPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      logger.i('Download started: $taskId');
      return taskId;
    } catch (e) {
      logger.e('Error downloading file: $e');
      throw Exception('Failed to download file');
    }
  }

  Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
  }


  Future<void> pauseDownload(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
  }

  Future<String?> resumeDownload(String taskId) async {
    return await FlutterDownloader.resume(taskId: taskId);
  }
}
