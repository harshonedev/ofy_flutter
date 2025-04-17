import 'package:equatable/equatable.dart';
import '../../../../core/constants/model_type.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ModelType modelType;
  final String? apiKey;
  final bool? saveSuccess;

  const SettingsLoaded({
    required this.modelType,
    this.apiKey,
    this.saveSuccess,
  });

  @override
  List<Object?> get props => [modelType, apiKey, saveSuccess];

  SettingsLoaded copyWith({
    ModelType? modelType,
    String? apiKey,
    bool? saveSuccess,
  }) {
    return SettingsLoaded(
      modelType: modelType ?? this.modelType,
      apiKey: apiKey ?? this.apiKey,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
