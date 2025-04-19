import 'package:equatable/equatable.dart';

import '../../../../core/constants/model_type.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class GetSettingsEvent extends SettingsEvent {}

class SaveModelTypeEvent extends SettingsEvent {
  final ModelType modelType;

  const SaveModelTypeEvent({required this.modelType});

  @override
  List<Object?> get props => [modelType];
}

class GetApiKeyEvent extends SettingsEvent {
  final ModelType modelType;

  const GetApiKeyEvent({required this.modelType});

  @override
  List<Object?> get props => [modelType];
}

class SaveApiKeyEvent extends SettingsEvent {
  final String apiKey;
  final ModelType modelType;

  const SaveApiKeyEvent({required this.apiKey, required this.modelType});

  @override
  List<Object?> get props => [apiKey, modelType];
}

class GetModelNameEvent extends SettingsEvent {
  final ModelType modelType;

  const GetModelNameEvent({required this.modelType});

  @override
  List<Object?> get props => [modelType];
}

class SaveModelNameEvent extends SettingsEvent {
  final String modelName;
  final ModelType modelType;

  const SaveModelNameEvent({required this.modelName, required this.modelType});

  @override
  List<Object?> get props => [modelName, modelType];
}
