import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';

abstract class DownloadManagerState extends Equatable {
  const DownloadManagerState();

  @override
  List<Object?> get props => [];
}

class InitialDownloadManagerState extends DownloadManagerState {}

class LoadingModelsState extends DownloadManagerState {}

class LoadedModelsState extends DownloadManagerState {
  final List<Model> models;

  const LoadedModelsState(this.models);

  @override
  List<Object> get props => [models];
}

class LoadingModelDetailsState extends DownloadManagerState {}

class LoadedModelDetailsState extends DownloadManagerState {
  final ModelDetails model;

  const LoadedModelDetailsState(this.model);

  @override
  List<Object> get props => [model];
}

class DownloadingModelState extends DownloadManagerState {
  final int progress;

  const DownloadingModelState(this.progress);

  @override
  List<Object> get props => [progress];
}

class DownloadCompletedState extends DownloadManagerState {}

class ErrorState extends DownloadManagerState {
  final String message;

  const ErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class FileSizeFetchedState extends DownloadManagerState {
  final List<FileDetails> files;

  const FileSizeFetchedState(this.files);

  @override
  List<Object> get props => [files];
}

class FileSizeErrorState extends DownloadManagerState {
  final String message;

  const FileSizeErrorState(this.message);

  @override
  List<Object> get props => [message];
}