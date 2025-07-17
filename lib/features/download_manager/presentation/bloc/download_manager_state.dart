import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_file.dart';

abstract class DownloadManagerState extends Equatable {
  const DownloadManagerState();

  @override
  List<Object?> get props => [];
}

class InitialDownloadManagerState extends DownloadManagerState {
  const InitialDownloadManagerState();
}

class DownloadingModelState extends DownloadManagerState {
  final DownloadModel downloadModel;
  final bool isStopping;
  final String? error;

  const DownloadingModelState(
    this.downloadModel, {
    this.isStopping = false,
    this.error,
  });

  DownloadingModelState copyWith({
    DownloadModel? downloadModel,
    bool? isStopping,
    String? error,
  }) {
    return DownloadingModelState(
      downloadModel ?? this.downloadModel,
      error: error ?? this.error,
      isStopping: isStopping ?? this.isStopping,
    );
  }

  @override
  List<Object?> get props => [downloadModel, isStopping, error];
}

class DownloadCompletedState extends DownloadManagerState {
  const DownloadCompletedState();
}

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

class LoadingDownloadedModelsState extends DownloadManagerState {
  const LoadingDownloadedModelsState();
}

class LoadedDownloadedModelsState extends DownloadManagerState {
  final List<ModelFile> modelFiles;

  const LoadedDownloadedModelsState(this.modelFiles);

  @override
  List<Object> get props => [modelFiles];
}

class LoadingActiveDownloadsState extends DownloadManagerState {
  const LoadingActiveDownloadsState();
}

class DownloadProcessingState extends DownloadManagerState {
  const DownloadProcessingState();
}

class DownloadStartedState extends DownloadManagerState {
  const DownloadStartedState();
}
