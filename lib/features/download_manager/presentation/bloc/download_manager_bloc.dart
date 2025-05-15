import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/download_model.dart'
    as dm;
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_gguf_models.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';

class DownloadManagerBloc
    extends Bloc<DownloadManagerEvent, DownloadManagerState> {
  final GetGGUFModels getGGUFModels;
  final GetModelDetails getModelDetails;
  final dm.DownloadModel downloadModel;

  StreamSubscription? _downloadProgressSubscription;

  DownloadManagerBloc({
    required this.getGGUFModels,
    required this.getModelDetails,
    required this.downloadModel,
  }) : super(InitialDownloadManagerState()) {
    on<LoadModelsEvent>(_onLoadModels);
    on<LoadModelDetailsEvent>(_onLoadModelDetails);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
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

  Future<void> _onLoadModelDetails(
    LoadModelDetailsEvent event,
    Emitter<DownloadManagerState> emit,
  ) async {
    emit(LoadingModelDetailsState());

    final result = await getModelDetails(Params(modelId: event.modelId));

    result.fold(
      (failure) => emit(ErrorState(failure.message)),
      (model) => emit(LoadedModelDetailsState(model)),
    );
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
    return super.close();
  }
}
