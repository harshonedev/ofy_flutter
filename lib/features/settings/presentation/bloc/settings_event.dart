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

class GetApiKeyEvent extends SettingsEvent {}

class SaveApiKeyEvent extends SettingsEvent {
  final String apiKey;

  const SaveApiKeyEvent({required this.apiKey});

  @override
  List<Object?> get props => [apiKey];
}
