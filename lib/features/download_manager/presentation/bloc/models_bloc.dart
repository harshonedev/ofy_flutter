import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/file_size_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_file_size.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_gguf_models.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/usecases/get_model_details.dart';
import 'package:logger/logger.dart';

class ModelsBloc extends Bloc<ModelsEvent, ModelsState> {
  final GetGGUFModels getGGUFModels;
  final GetModelDetails getModelDetails;
  final GetFileSizeUseCase getFileSize;

  final Logger logger = Logger();

  StreamSubscription? _fileSizeSubscription;

  ModelsBloc({
    required this.getGGUFModels,
    required this.getModelDetails,
    required this.getFileSize,
  }) : super(InitialModelsState()) {
    on<LoadModelsEvent>(_onLoadModels);
    on<LoadModelDetailsEvent>(_onLoadModelDetails);
    on<FileSizeUpdateEvent>(_onFileSizeUpdate);
    on<FileSizeErrorEvent>(_onFileSizeError);
  }

  void _listenFileSizeStream(List<FileDetails> files) {
    _fileSizeSubscription?.cancel();
    _fileSizeSubscription = getFileSize(files).listen((fileSizeDetail) {
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
    Emitter<ModelsState> emit,
  ) async {
    emit(LoadingModelsState());

    final result = await getGGUFModels(NoParams());

    result.fold(
      (failure) => emit(ModelsErrorState(failure.message)),
      (models) => emit(LoadedModelsState(models)),
    );
  }

  Future<void> _onLoadModelDetails(
    LoadModelDetailsEvent event,
    Emitter<ModelsState> emit,
  ) async {
    emit(LoadingModelDetailsState());

    final result = await getModelDetails(Params(modelId: event.modelId));

    result.fold((failure) => emit(ModelsErrorState(failure.message)), (model) {
      emit(LoadedModelDetailsState(model));
      // Fetch file size after loading model details
      if (model.files != null && model.files!.isNotEmpty) {
        _listenFileSizeStream(model.files!);
      }
    });
  }

  Future<void> _onFileSizeError(
    FileSizeErrorEvent event,
    Emitter<ModelsState> emit,
  ) async {
    // Handle file size error
    emit(FileSizeErrorState(event.errorMessage));
  }

  Future<void> _onFileSizeUpdate(
    FileSizeUpdateEvent event,
    Emitter<ModelsState> emit,
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

  @override
  Future<void> close() {
    _fileSizeSubscription?.cancel();
    return super.close();
  }
}

// States
abstract class ModelsState extends Equatable {
  const ModelsState();

  @override
  List<Object?> get props => [];
}

class LoadingModelsState extends ModelsState {}

class LoadedModelsState extends ModelsState {
  final List<Model> models;

  const LoadedModelsState(this.models);

  @override
  List<Object> get props => [models];
}

class LoadingModelDetailsState extends ModelsState {}

class LoadedModelDetailsState extends ModelsState {
  final ModelDetails model;

  const LoadedModelDetailsState(this.model);

  @override
  List<Object> get props => [model];
}

class ModelsErrorState extends ModelsState {
  final String message;

  const ModelsErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class InitialModelsState extends ModelsState {}

class FileSizeFetchedState extends ModelsState {
  final List<FileDetails> files;

  const FileSizeFetchedState(this.files);

  @override
  List<Object> get props => [files];
}

class FileSizeErrorState extends ModelsState {
  final String message;

  const FileSizeErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// Events
abstract class ModelsEvent extends Equatable {
  const ModelsEvent();

  @override
  List<Object> get props => [];
}

class FileSizeUpdateEvent extends ModelsEvent {
  final FileSizeDetails fileSizeDetails;

  const FileSizeUpdateEvent(this.fileSizeDetails);

  @override
  List<Object> get props => [fileSizeDetails];
}

class FileSizeErrorEvent extends ModelsEvent {
  final String errorMessage;

  const FileSizeErrorEvent(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class LoadModelsEvent extends ModelsEvent {}

class LoadModelDetailsEvent extends ModelsEvent {
  final String modelId;

  const LoadModelDetailsEvent(this.modelId);

  @override
  List<Object> get props => [modelId];
}
