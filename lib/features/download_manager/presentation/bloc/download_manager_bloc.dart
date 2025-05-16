import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/download_model.dart'
    as dm;
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_file_size.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_gguf_models.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';

class DownloadManagerBloc
    extends Bloc<DownloadManagerEvent, DownloadManagerState> {
  final GetGGUFModels getGGUFModels;
  final GetModelDetails getModelDetails;
  final GetFileSizeUseCase getFileSizeUseCase;
  final dm.DownloadModel downloadModel;

  StreamSubscription? _downloadProgressSubscription;
  StreamSubscription? _fileSizeSubscription;

  DownloadManagerBloc({
    required this.getGGUFModels,
    required this.getModelDetails,
    required this.downloadModel,
    required this.getFileSizeUseCase,
  }) : super(InitialDownloadManagerState()) {
    on<LoadModelsEvent>(_onLoadModels);
    on<LoadModelDetailsEvent>(_onLoadModelDetails);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<FileSizeUpdateEvent>(_onFileSizeUpdate);
    on<FileSizeErrorEvent>(_onFileSizeError);
  }

  void _listenFileSizeStream(List<FileDetails> files) {
    _fileSizeSubscription?.cancel();
    _fileSizeSubscription = getFileSizeUseCase(files).listen((fileSizeDetail) {
      // Handle the file size update
      fileSizeDetail.fold(
        (failure) => add(FileSizeErrorEvent(failure.message)),
        (fileSizeDetail) {
          // Emit the file size
          print("File size details: $fileSizeDetail");
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
    emit(const DownloadingModelState(0));

    // Call the use case to start download
    final result = await downloadModel(
      dm.Params(modelFileName: event.fileName),
    );

    result.fold(
      (failure) => emit(ErrorState(failure.message)),
      (_) => emit(DownloadCompletedState()),
    );
  }

  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    // Logic to cancel download
    _downloadProgressSubscription?.cancel();
    emit(InitialDownloadManagerState());
  }

  @override
  Future<void> close() {
    _downloadProgressSubscription?.cancel();
    _fileSizeSubscription?.cancel();
    return super.close();
  }
}
