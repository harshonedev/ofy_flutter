import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/models/download_model_data.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/cancel_download.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/download_model_usecase.dart'
    as dm;
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_active_downloads.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_available_models.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/pause_download.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/remove_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/resume_download.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';
import 'package:logger/logger.dart';

/// This function must be a top-level or static method!
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(
    'downloader_send_port',
  );
  send?.send([id, status, progress]);
}

class DownloadManagerBloc
    extends Bloc<DownloadManagerEvent, DownloadManagerState> {
  final dm.DownloadModelUsecase downloadModel;
  final GetActiveDownloads getActiveDownloads;
  final CancelDownload cancelDownload;
  final PauseDownload pauseDownload;
  final ResumeDownload resumeDownload;
  final GetAvailableModels getAvailableModels;
  final RemoveModel removeModel;

  final Logger logger = Logger();

  final ReceivePort _port = ReceivePort();

  DownloadManagerBloc({
    required this.downloadModel,
    required this.getActiveDownloads,
    required this.cancelDownload,
    required this.pauseDownload,
    required this.resumeDownload,
    required this.removeModel,
    required this.getAvailableModels,
  }) : super(InitialDownloadManagerState()) {
    // Register the port with a name
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    // Register the callback for download progress
    FlutterDownloader.registerCallback(downloadCallback);

    // Listen for download progress updates
    _port.listen((dynamic data) {
      final String id = data[0];
      final int status = data[1];
      final int progress = data[2];

      logger.i("Download progress: $progress");
      logger.i(
        "Download status: $status, Download Task Status - ${DownloadTaskStatus.fromInt(status)}",
      );
      logger.i("Download id: $id");

      if (DownloadTaskStatus.fromInt(status) == DownloadTaskStatus.complete) {
        add(_DownloadCompleted(id));
      } else if (DownloadTaskStatus.fromInt(status) ==
          DownloadTaskStatus.failed) {
        add(_DownloadFailedEvent(id, 'Download failed'));
      } else {
        add(_DownloadProgress(id, progress));
      }
    });

    on<LoadActiveDownloadsEvent>(_onLoadActiveDownloads);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<PauseDownloadEvent>(_onPauseDownload);
    on<ResumeDownloadEvent>(_onResumeDownload);
    on<LoadDownloadedModelsEvent>(_onLoadDownloadedModels);
    on<RemoveModelEvent>(_onRemoveModel);

    // Internal update
    on<_DownloadProgress>((event, emit) {
      final currentState = state;
      final isPaused =
          currentState is DownloadingModelState
              ? currentState.downloadModel.isPaused
              : false;
      final fileUrl =
          currentState is DownloadingModelState
              ? currentState.downloadModel.fileUrl
              : '';
      final fileName =
          currentState is DownloadingModelState
              ? currentState.downloadModel.fileName
              : 'Model File';
      emit(
        DownloadingModelState(
          DownloadModel(
            taskId: event.taskId,
            fileName: fileName,
            fileUrl: fileUrl,
            progress: event.progress,
            status: DownloadTaskStatus.running.name,
            isPaused: isPaused,
          ),
        ),
      );
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
    final result = await getActiveDownloads(NoParams());
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      activeDownloads,
    ) {
      if (activeDownloads.isNotEmpty) {
        logger.i("Active downloads: $activeDownloads");

        final DownloadModel activeDownloadModel = activeDownloads.firstWhere(
          (model) =>
              model.status == DownloadTaskStatus.running.name ||
              model.status == DownloadTaskStatus.paused.name,

          orElse:
              () => DownloadModelData(
                taskId: '',
                fileName: '',
                fileUrl: '',
                progress: 0,
                status: DownloadTaskStatus.enqueued.name,
                isPaused: false,
              ),
        );
        logger.i("Active model: $activeDownloadModel");
        if (activeDownloadModel.taskId != '') {
          emit(DownloadingModelState(activeDownloadModel));
        } else {
          emit(InitialDownloadManagerState());
        }
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
    final result = await downloadModel(
      dm.Params(modelFileName: event.fileName, modelFileUrl: event.fileUrl),
    );

    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      taskId,
    ) {
      if (taskId != null) {
        emit(DownloadStartedState());
        final downloadModel = DownloadModel(
          taskId: taskId,
          fileName: event.fileName,
          fileUrl: event.fileUrl,
          progress: 0,
          status: DownloadTaskStatus.enqueued.name,
          isPaused: false,
        );

        emit(DownloadingModelState(downloadModel));
      } else {
        emit(const DownloadErrorState("Failed to start download"));
      }
    });
  }

  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Logic to cancel download
    await cancelDownload(event.taskId);
    emit(DownloadCancelledState(event.taskId));
  }

  Future<void> _onPauseDownload(
    PauseDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // We should pause the download using FlutterDownloader
    await pauseDownload(event.taskId);

    // Update the state to reflect the paused status
    if (state is DownloadingModelState) {
      final currentState = state as DownloadingModelState;
      final downloadModel = currentState.downloadModel.copyWith(
        isPaused: true,
        status: DownloadTaskStatus.paused.name,
      );
      emit(DownloadingModelState(downloadModel));
    }
  }

  Future<void> _onResumeDownload(
    ResumeDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Resume the download using FlutterDownloader
    final result = await resumeDownload(event.taskId);

    result.fold((failure) => emit(DownloadErrorState(failure.message)), (
      taskId,
    ) {
      // Update the state to reflect the resumed status
      if (state is DownloadingModelState) {
        final currentState = state as DownloadingModelState;
        final downloadModel = currentState.downloadModel.copyWith(
          isPaused: false,
          status: DownloadTaskStatus.running.name,
          taskId: taskId,
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

    final result = await getAvailableModels(NoParams());
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
    final result = await removeModel(event.taskId);
    result.fold((failure) => emit(DownloadErrorState(failure.message)), (_) {
      add(LoadDownloadedModelsEvent());
    });
  }

  @override
  Future<void> close() {
    _port.close();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    return super.close();
  }
}

// Internal events
class _DownloadProgress extends DownloadManagerEvent {
  final String taskId;
  final int progress;
  const _DownloadProgress(this.taskId, this.progress);
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
