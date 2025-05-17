import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/download_model.dart'
    as dm;
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_file_size.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_gguf_models.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';
import 'package:logger/logger.dart';

class DownloadManagerBloc
    extends Bloc<DownloadManagerEvent, DownloadManagerState> {
  final GetGGUFModels getGGUFModels;
  final GetModelDetails getModelDetails;
  final GetFileSizeUseCase getFileSizeUseCase;
  final dm.DownloadModel downloadModel;

  StreamSubscription? _fileSizeSubscription;

  final Logger logger = Logger();

  final ReceivePort _port = ReceivePort();

  DownloadManagerBloc({
    required this.getGGUFModels,
    required this.getModelDetails,
    required this.downloadModel,
    required this.getFileSizeUseCase,
  }) : super(InitialDownloadManagerState()) {
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
      } else if (status == DownloadTaskStatus.failed) {
        add(_DownloadFailedEvent(id, 'Download failed'));
      } else {
        add(_DownloadProgress(id, progress));
      }
    });

    on<LoadModelsEvent>(_onLoadModels);
    on<LoadModelDetailsEvent>(_onLoadModelDetails);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<FileSizeUpdateEvent>(_onFileSizeUpdate);
    on<FileSizeErrorEvent>(_onFileSizeError);

    // Internal update
    on<_DownloadProgress>((event, emit) {
      emit(DownloadingModelState(event.progress, event.taskId));
    });

    on<_DownloadCompleted>((event, emit) {
      emit(DownloadCompletedState());
    });

    on<_DownloadFailedEvent>((event, emit) {
      emit(DownloadErrorState(event.error));
    });
  }

  void _listenFileSizeStream(List<FileDetails> files) {
    _fileSizeSubscription?.cancel();
    _fileSizeSubscription = getFileSizeUseCase(files).listen((fileSizeDetail) {
      // Handle the file size update
      fileSizeDetail.fold(
        (failure) => add(FileSizeErrorEvent(failure.message)),
        (fileSizeDetail) {
          // Emit the file size
          logger.i("File size details: $fileSizeDetail");
          add(FileSizeUpdateEvent(fileSizeDetail));
        },
      );
    });
  }

  Future<void> _onLoadModels(
    LoadModelsEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    emit(LoadingModelsState());

    final result = await getGGUFModels(NoParams());

    result.fold(
      (failure) => emit(ErrorState(failure.message)),
      (models) => emit(LoadedModelsState(models)),
    );
  }

  Future<void> _onFileSizeError(
    FileSizeErrorEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Handle file size error
    emit(FileSizeErrorState(event.errorMessage));
  }

  Future<void> _onLoadModelDetails(
    LoadModelDetailsEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    emit(LoadingModelDetailsState());

    final result = await getModelDetails(Params(modelId: event.modelId));

    result.fold((failure) => emit(ErrorState(failure.message)), (model) {
      emit(LoadedModelDetailsState(model));
      // Fetch file size after loading model details
      if (model.files != null && model.files!.isNotEmpty) {
        _listenFileSizeStream(model.files!);
      }
    });
  }

  Future<void> _onFileSizeUpdate(
    FileSizeUpdateEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    if (state is! LoadedModelDetailsState) {
      return;
    }
    final currentState = state as LoadedModelDetailsState;
    final updatedFiles = List<FileDetails>.from(currentState.model.files!);
    updatedFiles[event.fileSizeDetails.fileIndex] = currentState
        .model
        .files![event.fileSizeDetails.fileIndex]
        .copyWith(fileSize: event.fileSizeDetails.formattedSize);

    final updatedModel = currentState.model.copyWith(files: updatedFiles);
    emit(LoadedModelDetailsState(updatedModel));
  }

  Future<void> _onDownloadModel(
    DownloadModelEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Call the use case to start download
    final result = await downloadModel(
      dm.Params(modelFileName: event.fileName, modelFileUrl: event.fileUrl),
    );

    result.fold((failure) => emit(ErrorState(failure.message)), (taskId) {
      if (taskId != null) {
        emit(DownloadingModelState(0, taskId));
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
    emit(InitialDownloadManagerState());
  }

  @override
  Future<void> close() {
    _fileSizeSubscription?.cancel();
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

/// This function must be a top-level or static method!
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(
    'downloader_send_port',
  );
  send?.send([id, status, progress]);
}
