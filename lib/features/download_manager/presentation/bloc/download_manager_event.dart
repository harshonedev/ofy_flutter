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
  final String taskId;

  const CancelDownloadEvent(this.taskId);

  @override
  List<Object> get props => [taskId]; 
}

class PauseDownloadEvent extends DownloadManagerEvent {
  final String taskId;

  const PauseDownloadEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class ResumeDownloadEvent extends DownloadManagerEvent {
  final String taskId;

  const ResumeDownloadEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class RemoveModelEvent extends DownloadManagerEvent {
  final String taskId;

  const RemoveModelEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}
