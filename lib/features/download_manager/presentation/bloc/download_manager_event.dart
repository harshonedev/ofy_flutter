import 'package:background_downloader/background_downloader.dart';
import 'package:equatable/equatable.dart';

abstract class DownloadManagerEvent extends Equatable {
  const DownloadManagerEvent();

  @override
  List<Object> get props => [];
}
class LoadDownloadedModelsEvent extends DownloadManagerEvent {}

class LoadActiveDownloadsEvent extends DownloadManagerEvent {}

class DownloadModelEvent extends DownloadManagerEvent {
  final String fileName;
  final String fileUrl;

  const DownloadModelEvent(this.fileName, this.fileUrl);

  @override
  List<Object> get props => [fileName];
}

class CancelDownloadEvent extends DownloadManagerEvent {
  final Task task;

  const CancelDownloadEvent(this.task);

  @override
  List<Object> get props => [task]; 
}

class PauseDownloadEvent extends DownloadManagerEvent {
  final Task task;

  const PauseDownloadEvent(this.task);

  @override
  List<Object> get props => [task];
}

class ResumeDownloadEvent extends DownloadManagerEvent {
  final Task task;

  const ResumeDownloadEvent(this.task);

  @override
  List<Object> get props => [task];
}

class RemoveModelEvent extends DownloadManagerEvent {
  final String taskId;
  final String filePath;

  const RemoveModelEvent(this.taskId, this.filePath);

  @override
  List<Object> get props => [taskId, filePath];
}
