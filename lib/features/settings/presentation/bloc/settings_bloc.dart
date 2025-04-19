import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/core/constants/model_type.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';

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
    print("GetSettingsEvent called");
    final modelTypeResult = await getModelTypePreference(NoParams());

    if (modelTypeResult.isLeft()) {
      emit(
        SettingsError(
          message:
              modelTypeResult
                  .swap()
                  .getOrElse(() => const UnknownFailure("Unknown error"))
                  .message,
        ),
      );
      return;
    }
    final modelType = modelTypeResult.getOrElse(() => ModelType.local);
    emit(SettingsLoaded(modelType: modelType));
    print("Model type: $modelType");
    // CHECK IF THE MODEL TYPE IS NOT LOCAL
    if (modelType != ModelType.local) {
      // fetch api key and model name
      add(GetApiKeyEvent(modelType: modelType));
      add(GetModelNameEvent(modelType: modelType));
    }
  }

  Future<void> _onSaveModelType(
    SaveModelTypeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      final params = SaveModelTypeParams(modelType: event.modelType);
      final result = await saveModelTypePreference(params);

      if (result.isLeft()) {
        emit(
          SettingsError(
            message:
                result
                    .swap()
                    .getOrElse(() => const UnknownFailure("Unknown error"))
                    .message,
          ),
        );
        return;
      }
      if (result.getOrElse(() => false)) {
        emit(
          currentState.copyWith(modelType: event.modelType, saveSuccess: false),
        );

        if (event.modelType != ModelType.local) {
          // fetch api key and model name
          add(GetApiKeyEvent(modelType: event.modelType));
          add(GetModelNameEvent(modelType: event.modelType));
        }
      } else {
        emit(
          const SettingsError(message: 'Failed to save model type preference'),
        );
      }
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
