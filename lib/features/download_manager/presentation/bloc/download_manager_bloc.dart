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
  final Logger _logger = Logger();

  // Stream subscriptions for proper disposal
  late final StreamSubscription _progressSubscription;
  late final StreamSubscription _statusSubscription;

  // Flags to prevent duplicate operations
  bool _isPauseResumeInProgress = false;
  bool _isCancelInProgress = false;

  DownloadManagerBloc({required this.downloadRepository})
    : super(const InitialDownloadManagerState()) {
    _initializeSubscriptions();
    _setupEventHandlers();
    downloadRepository.startFileDownloader();
  }

  void _initializeSubscriptions() {
    downloadRepository.startListeningToDownloads();

    // Listen to download progress updates with error handling
    _progressSubscription = downloadRepository
        .downloadProgressStream()
        .handleError(_handleStreamError)
        .listen(_handleProgressUpdate);

    // Listen to download status updates with error handling
    _statusSubscription = downloadRepository
        .downloadStatusStream()
        .handleError(_handleStreamError)
        .listen(_handleStatusUpdate);
  }

  void _handleProgressUpdate(progress) {
    add(
      _DownloadProgress(
        progress.task,
        (progress.progress * 100).round(),
        networkSpeed: progress.networkSpeed,
        timeRemaining: progress.timeRemaining,
        expectedFileSize: progress.expectedFileSize,
      ),
    );
  }

  void _handleStatusUpdate(status) {
    switch (status.status) {
      case TaskStatus.complete:
        add(_DownloadCompleted(status.task.taskId));
        break;
      case TaskStatus.failed:
        add(_DownloadFailedEvent(status.task.taskId, "Download failed"));
        break;
      case TaskStatus.canceled:
      case TaskStatus.paused:
      case TaskStatus.running:
        add(_DownloadStatusUpdate(status.task, status.status));
        break;
      default:
        _logger.w('Unhandled download status: ${status.status}');
    }
  }

  void _handleStreamError(error) {
    _logger.e('Stream error: $error');
    add(_DownloadFailedEvent('', 'Stream error: $error'));
  }

  void _setupEventHandlers() {
    on<LoadActiveDownloadsEvent>(_onLoadActiveDownloads);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<PauseDownloadEvent>(_onPauseDownload);
    on<ResumeDownloadEvent>(_onResumeDownload);
    on<LoadDownloadedModelsEvent>(_onLoadDownloadedModels);
    on<RemoveModelEvent>(_onRemoveModel);

    // Internal update
    on<_DownloadProgress>((event, emit) async {
      _logger.i(
        "Download progress for task ${event.task.taskId}: ${event.progress}%",
      );
      if (state is DownloadingModelState) {
        final currentState = state as DownloadingModelState;
        _logger.i(
          "Current download model task ID: ${currentState.downloadModel.task.taskId}",
        );
        if (currentState.downloadModel.task.taskId != event.task.taskId) {
          return; // Ignore progress for other tasks
        }
        final downloadModel = currentState.downloadModel.copyWith(
          progress:
              event.progress < 0
                  ? currentState.downloadModel.progress
                  : event.progress,
          status: TaskStatus.running.name,
          isPaused: false,
          networkSpeed: event.networkSpeed,
          timeRemaining: event.timeRemaining,
          expectedFileSize:
              event.expectedFileSize == '-1 bytes'
                  ? currentState.downloadModel.expectedFileSize
                  : event.expectedFileSize,
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

    on<_DownloadStatusUpdate>((event, emit) async {
      _logger.i(
        "Download status update for task ${event.task.taskId}: ${event.status}",
      );
      if (state is DownloadingModelState) {
        final currentState = state as DownloadingModelState;
        if (currentState.downloadModel.task.taskId != event.task.taskId) {
          return; // Ignore status updates for other tasks
        }
        final downloadModel = currentState.downloadModel.copyWith(
          status: event.status.name,
          isPaused: event.status == TaskStatus.paused,
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
              status: event.status.name,
              isPaused: event.status == TaskStatus.paused,
            ),
          ),
        );
      }
    });

    on<_DownloadCompleted>((event, emit) {
      _resetOperationFlags();
      emit(const DownloadCompletedState());
      add(const LoadDownloadedModelsEvent());
    });

    on<_DownloadFailedEvent>((event, emit) {
      _resetOperationFlags();
      emit(DownloadErrorState(event.error));
    });
  }

  void _resetOperationFlags() {
    _isPauseResumeInProgress = false;
    _isCancelInProgress = false;
  }

  Future<void> _onLoadActiveDownloads(
    LoadActiveDownloadsEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    emit(const LoadingActiveDownloadsState());
    final result = await downloadRepository.getActiveDownloads();
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      activeDownloads,
    ) {
      if (activeDownloads.isNotEmpty) {
        _logger.i("Active downloads: $activeDownloads");
        emit(DownloadingModelState(activeDownloads.first));
      } else {
        emit(const InitialDownloadManagerState());
      }
    });
  }

  Future<void> _onDownloadModel(
    DownloadModelEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Prevent multiple simultaneous downloads
    if (_isDownloadInProgress()) {
      emit(const DownloadErrorState("A download is already in progress"));
      return;
    }

    emit(const DownloadProcessingState());

    try {
      final result = await downloadRepository.downloadModel(
        event.fileUrl,
        event.fileName,
      );

      emit(const DownloadStartedState());

      result.fold(
        (failure) => emit(DownloadErrorState(failure.message)),
        (downloadModel) => emit(DownloadingModelState(downloadModel)),
      );
    } catch (e) {
      emit(DownloadErrorState('Failed to start download: $e'));
    }
  }

  bool _isDownloadInProgress() {
    return state is DownloadingModelState ||
        state is DownloadProcessingState ||
        state is DownloadStartedState;
  }

  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Prevent duplicate cancel operations
    if (_isCancelInProgress) {
      _logger.w(
        'Cancel operation already in progress, ignoring duplicate request',
      );
      return;
    }

    if (state is! DownloadingModelState) {
      _isCancelInProgress = true;
      await downloadRepository.cancelDownload(event.task);
      _isCancelInProgress = false;
      return;
    }

    final currentState = state as DownloadingModelState;
    _isCancelInProgress = true;
    emit(currentState.copyWith(isStopping: true));

    try {
      final result = await downloadRepository.cancelDownload(event.task);
      result.fold((failure) => emit(DownloadErrorState(failure.message)), (
        isCancelled,
      ) {
        if (isCancelled) {
          emit(DownloadCancelledState(event.task.taskId));
        } else {
          emit(currentState.copyWith(error: "Failed to cancel download"));
        }
      });
    } catch (e) {
      emit(DownloadErrorState('Error cancelling download: $e'));
    } finally {
      _isCancelInProgress = false;
      _isPauseResumeInProgress = false; // Reset both flags on cancel
    }
  }

  Future<void> _onPauseDownload(
    PauseDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Prevent duplicate pause operations
    if (_isPauseResumeInProgress) {
      _logger.w(
        'Pause operation already in progress, ignoring duplicate request',
      );
      return;
    }

    if (state is! DownloadingModelState) {
      _isPauseResumeInProgress = true;
      await downloadRepository.pauseDownload(event.task);
      _isPauseResumeInProgress = false;
      return;
    }

    final currentState = state as DownloadingModelState;

    // Check if task matches current download
    if (currentState.downloadModel.task.taskId != event.task.taskId) {
      _logger.w('Task ID mismatch, ignoring pause request');
      return;
    }

    // Check if already paused
    if (currentState.downloadModel.isPaused) {
      _logger.w('Download is already paused, ignoring pause request');
      return;
    }

    _isPauseResumeInProgress = true;
    emit(currentState.copyWith(isStopping: true));

    try {
      final result = await downloadRepository.pauseDownload(event.task);
      result.fold((failure) => emit(DownloadErrorState(failure.message)), (
        isPaused,
      ) {
        if (isPaused) {
          final downloadModel = currentState.downloadModel.copyWith(
            isPaused: true,
            status: TaskStatus.paused.name,
          );
          emit(DownloadingModelState(downloadModel, isStopping: false));
        } else {
          emit(currentState.copyWith(error: "Failed to pause download"));
        }
      });
    } catch (e) {
      emit(DownloadErrorState('Error pausing download: $e'));
    } finally {
      _isPauseResumeInProgress = false;
    }
  }

  Future<void> _onResumeDownload(
    ResumeDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Prevent duplicate resume operations
    if (_isPauseResumeInProgress) {
      _logger.w(
        'Resume operation already in progress, ignoring duplicate request',
      );
      return;
    }

    if (state is! DownloadingModelState) {
      _isPauseResumeInProgress = true;
      await downloadRepository.resumeDownload(event.task);
      _isPauseResumeInProgress = false;
      return;
    }

    final currentState = state as DownloadingModelState;

    // Check if task matches current download
    if (currentState.downloadModel.task.taskId != event.task.taskId) {
      _logger.w('Task ID mismatch, ignoring resume request');
      return;
    }

    // Check if already running
    if (!currentState.downloadModel.isPaused) {
      _logger.w('Download is already running, ignoring resume request');
      return;
    }

    _isPauseResumeInProgress = true;
    emit(currentState.copyWith(isStopping: false));

    try {
      final result = await downloadRepository.resumeDownload(event.task);
      result.fold((failure) => emit(DownloadErrorState(failure.message)), (
        isResumed,
      ) {
        if (isResumed) {
          final downloadModel = currentState.downloadModel.copyWith(
            isPaused: false,
            status: TaskStatus.running.name,
          );
          emit(DownloadingModelState(downloadModel, isStopping: false));
        } else {
          emit(currentState.copyWith(error: "Failed to resume download"));
        }
      });
    } catch (e) {
      emit(DownloadErrorState('Error resuming download: $e'));
    } finally {
      _isPauseResumeInProgress = false;
    }
  }

  Future<void> _onLoadDownloadedModels(
    LoadDownloadedModelsEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    emit(const LoadingDownloadedModelsState());

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
    final result = await downloadRepository.deleteDownload(
      event.taskId,
      event.filePath,
    );
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (_) {
      add(const LoadDownloadedModelsEvent());
    });
  }

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    await _statusSubscription.cancel();
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

class _DownloadStatusUpdate extends DownloadManagerEvent {
  final Task task;
  final TaskStatus status;

  const _DownloadStatusUpdate(this.task, this.status);
}
