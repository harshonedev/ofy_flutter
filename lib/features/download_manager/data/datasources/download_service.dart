import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:llm_cpp_chat_app/core/constants/app_constants.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadService {
  final Logger logger = Logger();
  final SharedPreferences sharedPreferences;

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

  Future<List<DownloadTask>?> loadDownlaods() async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks != null) {
        for (var task in tasks) {
          logger.i(
            'Task ID: ${task.taskId}, Status: ${task.status}, Progress: ${task.progress}, File Name: ${task.filename}, Dir: ${task.savedDir}',
          );
        }
      }
      return tasks;
    } catch (e) {
      logger.e('Error loading downloads: $e');
      throw Exception('Failed to load downloads');
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

  Future<void> deleteDownload(String taskId) async {
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
  }
}
