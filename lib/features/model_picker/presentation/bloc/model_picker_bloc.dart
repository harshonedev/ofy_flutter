import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_model_path.dart';
import '../../domain/usecases/save_model_path.dart';
import 'model_picker_event.dart';
import 'model_picker_state.dart';

class ModelPickerBloc extends Bloc<ModelPickerEvent, ModelPickerState> {
  final GetModelPath getModelPath;
  final SaveModelPath saveModelPath;

  ModelPickerBloc({required this.getModelPath, required this.saveModelPath})
    : super(ModelPickerInitial()) {
    on<GetModelPathEvent>(_onGetModelPath);
    on<SaveModelPathEvent>(_onSaveModelPath);
    on<SelectModelEvent>(_onSelectModel);
  }

  Future<void> _onGetModelPath(
    GetModelPathEvent event,
    Emitter<ModelPickerState> emit,
  ) async {
    emit(ModelPickerLoading());

    final result = await getModelPath(NoParams());

    result.fold(
      (failure) => emit(ModelPickerError(message: failure.toString())),
      (modelPath) => emit(
        ModelPickerLoaded(
          modelPath: modelPath,
          isModelSelected: modelPath != null && modelPath.isNotEmpty,
        ),
      ),
    );
  }

  Future<void> _onSaveModelPath(
    SaveModelPathEvent event,
    Emitter<ModelPickerState> emit,
  ) async {
    emit(ModelPickerLoading());

    final params = SaveModelPathParams(modelPath: event.modelPath);
    final result = await saveModelPath(params);

    result.fold(
      (failure) => emit(ModelPickerError(message: failure.toString())),
      (success) => emit(
        ModelPickerLoaded(
          modelPath: event.modelPath,
          saveSuccess: success,
          isModelSelected: true,
        ),
      ),
    );
  }

  Future<void> _onSelectModel(
    SelectModelEvent event,
    Emitter<ModelPickerState> emit,
  ) async {
    emit(ModelPickerLoading());

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          // Save the selected model path
          add(SaveModelPathEvent(modelPath: filePath));
        } else {
          emit(const ModelPickerError(message: 'Failed to get file path'));
        }
      } else {
        // User canceled the picker
        if (state is ModelPickerLoaded) {
          emit(state);
        } else {
          emit(const ModelPickerLoaded(isModelSelected: false));
        }
      }
    } catch (e) {
      emit(ModelPickerError(message: 'Error selecting file: $e'));
    }
  }
}
