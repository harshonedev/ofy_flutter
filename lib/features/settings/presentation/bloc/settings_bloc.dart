import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/core/constants/model_type.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_api_key.dart';
import '../../domain/usecases/get_model_name.dart';
import '../../domain/usecases/get_model_type_preference.dart';
import '../../domain/usecases/save_api_key.dart';
import '../../domain/usecases/save_model_name.dart';
import '../../domain/usecases/save_model_type_preference.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetModelTypePreference getModelTypePreference;
  final SaveModelTypePreference saveModelTypePreference;
  final GetApiKey getApiKey;
  final SaveApiKey saveApiKey;
  final GetModelName getModelName;
  final SaveModelName saveModelName;

  SettingsBloc({
    required this.getModelTypePreference,
    required this.saveModelTypePreference,
    required this.getApiKey,
    required this.saveApiKey,
    required this.getModelName,
    required this.saveModelName,
  }) : super(SettingsInitial()) {
    on<GetSettingsEvent>(_onGetSettings);
    on<SaveModelTypeEvent>(_onSaveModelType);
    on<GetApiKeyEvent>(_onGetApiKey);
    on<SaveApiKeyEvent>(_onSaveApiKey);
    on<GetModelNameEvent>(_onGetModelName);
    on<SaveModelNameEvent>(_onSaveModelName);
  }

  Future<void> _onGetSettings(
    GetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final modelTypeResult = await getModelTypePreference(NoParams());

    modelTypeResult.fold(
      (failure) => emit(SettingsError(message: failure.toString())),
      (modelType) {
        // Start with basic state
        var settingsState = SettingsLoaded(modelType: modelType);

      emit(settingsState);
        // Then load all API keys and model names for each model type
        //_loadModelSpecificSettings(settingsState, emit);
      },
    );
  }

  void _loadModelSpecificSettings(
    SettingsLoaded initialState,
    Emitter<SettingsState> emit,
  ) async {
    // Use the modelTypes from the enum to fetch all settings
    const modelTypes = ModelType.values;
    var currentState = initialState;

    for (var modelType in modelTypes) {
      // Get API key for this model type
      final apiKeyResult = await getApiKey(
        GetApiKeyParams(modelType: modelType),
      );
      apiKeyResult.fold(
        (failure) {
          /* ignore failure, just don't update state */
        },
        (apiKey) {
          currentState = currentState.updateApiKey(modelType, apiKey);
        },
      );

      // Get model name for this model type
      final modelNameResult = await getModelName(
        GetModelNameParams(modelType: modelType),
      );
      modelNameResult.fold(
        (failure) {
          /* ignore failure, just don't update state */
        },
        (modelName) {
          currentState = currentState.updateModelName(modelType, modelName);
        },
      );
    }

    emit(currentState);
  }

  Future<void> _onSaveModelType(
    SaveModelTypeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsLoading());

      final params = SaveModelTypeParams(modelType: event.modelType);
      final result = await saveModelTypePreference(params);

      result.fold(
        (failure) => emit(SettingsError(message: failure.toString())),
        (success) => emit(
          currentState.copyWith(
            modelType: event.modelType,
            saveSuccess: success,
          ),
        ),
      );
    }
  }

  Future<void> _onGetApiKey(
    GetApiKeyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      final params = GetApiKeyParams(modelType: event.modelType);
      final result = await getApiKey(params);

      result.fold(
        (failure) => emit(SettingsError(message: failure.toString())),
        (apiKey) => emit(currentState.updateApiKey(event.modelType, apiKey)),
      );
    }
  }

  Future<void> _onSaveApiKey(
    SaveApiKeyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsLoading());

      final params = SaveApiKeyParams(
        apiKey: event.apiKey,
        modelType: event.modelType,
      );
      final result = await saveApiKey(params);

      result.fold(
        (failure) => emit(SettingsError(message: failure.toString())),
        (success) => emit(
          currentState
              .updateApiKey(event.modelType, event.apiKey)
              .copyWith(saveSuccess: success),
        ),
      );
    }
  }

  Future<void> _onGetModelName(
    GetModelNameEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      final params = GetModelNameParams(modelType: event.modelType);
      final result = await getModelName(params);

      result.fold(
        (failure) => emit(SettingsError(message: failure.toString())),
        (modelName) =>
            emit(currentState.updateModelName(event.modelType, modelName)),
      );
    }
  }

  Future<void> _onSaveModelName(
    SaveModelNameEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsLoading());

      final params = SaveModelNameParams(
        modelName: event.modelName,
        modelType: event.modelType,
      );
      final result = await saveModelName(params);

      result.fold(
        (failure) => emit(SettingsError(message: failure.toString())),
        (success) => emit(
          currentState
              .updateModelName(event.modelType, event.modelName)
              .copyWith(saveSuccess: success),
        ),
      );
    }
  }
}
