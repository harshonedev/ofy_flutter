import 'package:background_downloader/background_downloader.dart';
import 'package:equatable/equatable.dart';

class DownloadModel extends Equatable {
  final Task task;
  final String fileName;
  final String filePath;
  final int progress;
  final String status;
  final String expectedFileSize;
  final String networkSpeed;
  final String timeRemaining;
  final bool isPaused;

  const DownloadModel({
    required this.task,
    required this.fileName,
    required this.filePath,
    this.progress = 0,
    this.status = 'enqueued',
    this.expectedFileSize = '',
    this.networkSpeed = '',
    this.timeRemaining = '',
    this.isPaused = false,
  });

  DownloadModel copyWith({
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
    return DownloadModel(
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

  @override
  List<Object> get props => [
    task,
    fileName,
    filePath,
    progress,
    status,
    expectedFileSize,
    networkSpeed,
    timeRemaining,
    isPaused,
  ];
}

