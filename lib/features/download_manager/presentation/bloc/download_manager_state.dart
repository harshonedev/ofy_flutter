import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_file.dart';

abstract class DownloadManagerState extends Equatable {
  const DownloadManagerState();

  @override
  List<Object?> get props => [];
}

class InitialDownloadManagerState extends DownloadManagerState {}

class DownloadingModelState extends DownloadManagerState {
  final DownloadModel downloadModel;
  final bool isStopping;

  const DownloadingModelState(this.downloadModel, {this.isStopping = false});

  DownloadingModelState copyWith({
    DownloadModel? downloadModel,
    bool? isStopping,
  }) {
    return DownloadingModelState(
      downloadModel ?? this.downloadModel,
      isStopping: isStopping ?? this.isStopping,
    );
  }

  @override
  List<Object> get props => [downloadModel];
}

class DownloadCompletedState extends DownloadManagerState {}

class DownloadCancelledState extends DownloadManagerState {
  final String taskId;

  const DownloadCancelledState(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class DownloadErrorState extends DownloadManagerState {
  final String message;

  const DownloadErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class LoadingDownloadedModelsState extends DownloadManagerState {}

class LoadedDownloadedModelsState extends DownloadManagerState {
  final List<ModelFile> modelFiles;

  const LoadedDownloadedModelsState(this.modelFiles);

  @override
  List<Object> get props => [modelFiles];
}

class LoadingActiveDownloadsState extends DownloadManagerState {}

class DownloadProcessingState extends DownloadManagerState {}

class DownloadStartedState extends DownloadManagerState {}
