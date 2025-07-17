import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';
import 'package:logger/logger.dart';

class DownloadManagerBloc
    extends Bloc<DownloadManagerEvent, DownloadManagerState> {
  final DownloadRepository downloadRepository;

  final Logger logger = Logger();

  DownloadManagerBloc({required this.downloadRepository})
    : super(InitialDownloadManagerState()) {
    // start listening to download updates
    downloadRepository.startListeningToDownloads();
    // Listen to download progress updates
    downloadRepository.downloadProgressStream().listen((progress) {
      add(
        _DownloadProgress(
          progress.task,
          (progress.progress / 100).toInt(),
          networkSpeed: progress.networkSpeed,
          timeRemaining: progress.timeRemaining,
          expectedFileSize: progress.expectedFileSize,
        ),
      );
    });

    // Listen to download status updates
    downloadRepository.downloadStatusStream().listen((status) {
      if (status.status == TaskStatus.complete) {
        add(_DownloadCompleted(status.task.taskId));
      } else if (status.status == TaskStatus.failed) {
        add(_DownloadFailedEvent(status.task.taskId, "Download failed"));
      }
    });

    // start the file downloader
    downloadRepository.startFileDownloader();

    on<LoadActiveDownloadsEvent>(_onLoadActiveDownloads);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<PauseDownloadEvent>(_onPauseDownload);
    on<ResumeDownloadEvent>(_onResumeDownload);
    on<LoadDownloadedModelsEvent>(_onLoadDownloadedModels);
    on<RemoveModelEvent>(_onRemoveModel);

    // Internal update
    on<_DownloadProgress>((event, emit) async {
      if (state is DownloadingModelState) {
        final currentState = state as DownloadingModelState;
        if (currentState.downloadModel.task.taskId != event.task.taskId) {
          return; // Ignore progress for other tasks
        }
        final downloadModel = currentState.downloadModel.copyWith(
          progress: event.progress,
          status: TaskStatus.running.name,
          isPaused: false,
          networkSpeed: event.networkSpeed,
          timeRemaining: event.timeRemaining,
          expectedFileSize: event.expectedFileSize,
        );
        emit(DownloadingModelState(downloadModel));
      } else {
        final filePath = await event.task.filePath(
          withFilename: event.task.filename,
        );
        emit(
          DownloadingModelState(
            DownloadModel(
              task: event.task,
              fileName: event.task.filename,
              filePath: filePath,
              progress: event.progress,
              status: TaskStatus.running.name,
              networkSpeed: event.networkSpeed,
              timeRemaining: event.timeRemaining,
              expectedFileSize: event.expectedFileSize,
            ),
          ),
        );
      }
    });

    on<_DownloadCompleted>((event, emit) {
      emit(DownloadCompletedState());
      add(LoadDownloadedModelsEvent());
    });

    on<_DownloadFailedEvent>((event, emit) {
      emit(DownloadErrorState(event.error));
    });
  }

  Future<void> _onLoadActiveDownloads(
    LoadActiveDownloadsEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    emit(LoadingActiveDownloadsState());
    final result = await downloadRepository.getActiveDownloads();
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      activeDownloads,
    ) {
      if (activeDownloads.isNotEmpty) {
        logger.i("Active downloads: $activeDownloads");
        emit(DownloadingModelState(activeDownloads.first));
      } else {
        emit(InitialDownloadManagerState());
      }
    });
  }

  Future<void> _onDownloadModel(
    DownloadModelEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Call the use case to start download
    if (state is DownloadingModelState ||
        state is DownloadProcessingState ||
        state is DownloadStartedState) {
      emit(const DownloadErrorState("A download is already in progress"));
      return;
    }

    emit(DownloadProcessingState());
    final result = await downloadRepository.downloadModel(
      event.fileUrl,
      event.fileName,
    );
    emit(DownloadStartedState());

    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      downloadModel,
    ) {
      emit(DownloadingModelState(downloadModel));
    });
  }

  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Logic to cancel download
    final result = await downloadRepository.cancelDownload(event.task);
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      isCancelled,
    ) {
      if (!isCancelled) {
        emit(const DownloadErrorState("Failed to cancel download"));
        return;
      }

      emit(DownloadCancelledState(event.task.taskId));
    });
  }

  Future<void> _onPauseDownload(
    PauseDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // We should pause the download using FlutterDownloader
    await downloadRepository.pauseDownload(event.task);

    // Update the state to reflect the paused status
    if (state is DownloadingModelState) {
      final currentState = state as DownloadingModelState;
      final downloadModel = currentState.downloadModel.copyWith(
        isPaused: true,
        status: TaskStatus.paused.name,
      );
      emit(DownloadingModelState(downloadModel));
    }
  }

  Future<void> _onResumeDownload(
    ResumeDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Resume the download using FlutterDownloader
    final result = await downloadRepository.resumeDownload(event.task);

    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      isResumed,
    ) {
      // Update the state to reflect the resumed status
      if (state is DownloadingModelState) {
        final currentState = state as DownloadingModelState;
        final downloadModel = currentState.downloadModel.copyWith(
          isPaused: false,
          status: TaskStatus.running.name,
        );
        emit(DownloadingModelState(downloadModel));
      }
    });
  }

  Future<void> _onLoadDownloadedModels(
    LoadDownloadedModelsEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    emit(LoadingDownloadedModelsState());

    final result = await downloadRepository.getAvailableModels();
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      modelFiles,
    ) {
      if (modelFiles.isNotEmpty) {
        emit(LoadedDownloadedModelsState(modelFiles));
      } else {
        emit(const LoadedDownloadedModelsState([]));
      }
    });
  }

  Future<void> _onRemoveModel(
    RemoveModelEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Logic to remove the model
    final result = await downloadRepository.deleteDownload(event.taskId);
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (_) {
      add(LoadDownloadedModelsEvent());
    });
  }

  @override
  Future<void> close() {
    downloadRepository.dispose();
    return super.close();
  }
}

// Internal events
class _DownloadProgress extends DownloadManagerEvent {
  final Task task;
  final int progress;
  final String networkSpeed;
  final String timeRemaining;
  final String expectedFileSize;

  const _DownloadProgress(
    this.task,
    this.progress, {
    this.networkSpeed = '',
    this.timeRemaining = '',
    this.expectedFileSize = '',
  });
}

class _DownloadCompleted extends DownloadManagerEvent {
  final String taskId;
  const _DownloadCompleted(this.taskId);
}

class _DownloadFailedEvent extends DownloadManagerEvent {
  final String taskId;
  final String error;
  const _DownloadFailedEvent(this.taskId, this.error);
}
