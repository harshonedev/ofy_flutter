import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_model_type_preference.dart';
import '../../domain/usecases/save_model_type_preference.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetModelTypePreference getModelTypePreference;
  final SaveModelTypePreference saveModelTypePreference;

  SettingsBloc({
    required this.getModelTypePreference,
    required this.saveModelTypePreference,
  }) : super(SettingsInitial()) {
    on<GetSettingsEvent>(_onGetSettings);
    on<SaveModelTypeEvent>(_onSaveModelType);
    on<GetApiKeyEvent>(_onGetApiKey);
    on<SaveApiKeyEvent>(_onSaveApiKey);
  }

  Future<void> _onGetSettings(
    GetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await getModelTypePreference(NoParams());

    result.fold(
      (failure) => emit(SettingsError(message: failure.toString())),
      (modelType) => emit(SettingsLoaded(modelType: modelType)),
    );
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
    // This would be implemented similarly as _onGetSettings
    // For now, we'll just handle the basic functionality
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState);
    }
  }

  Future<void> _onSaveApiKey(
    SaveApiKeyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    // This would be implemented similarly as _onSaveModelType
    // For now, we'll just handle the basic functionality
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(apiKey: event.apiKey, saveSuccess: true));
    }
  }
}
