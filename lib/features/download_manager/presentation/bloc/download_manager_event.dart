import 'package:equatable/equatable.dart';

abstract class DownloadManagerEvent extends Equatable {
  const DownloadManagerEvent();

  @override
  List<Object> get props => [];
}

class LoadModelsEvent extends DownloadManagerEvent {}

class LoadModelDetailsEvent extends DownloadManagerEvent {
  final String modelId;

  const LoadModelDetailsEvent(this.modelId);

  @override
  List<Object> get props => [modelId];
}

class DownloadModelEvent extends DownloadManagerEvent {
  final String fileName;

  const DownloadModelEvent(this.fileName);

  @override
  List<Object> get props => [fileName];
}

class CancelDownloadEvent extends DownloadManagerEvent {}
