import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/file_size_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';

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
  final String fileUrl;

  const DownloadModelEvent(this.fileName, this.fileUrl);

  @override
  List<Object> get props => [fileName];
}

class FetchFileSizeEvent extends DownloadManagerEvent {
  final List<FileDetails> files;

  const FetchFileSizeEvent(this.files);

  @override
  List<Object> get props => [files];
}

class FileSizeUpdateEvent extends DownloadManagerEvent {
  final FileSizeDetails fileSizeDetails;

  const FileSizeUpdateEvent(this.fileSizeDetails);

  @override
  List<Object> get props => [fileSizeDetails];
}

class FileSizeErrorEvent extends DownloadManagerEvent {
  final String errorMessage;

  const FileSizeErrorEvent(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class CancelDownloadEvent extends DownloadManagerEvent {}
