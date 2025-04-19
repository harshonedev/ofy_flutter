import 'package:equatable/equatable.dart';
import '../../../../core/constants/model_type.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ModelType modelType;
  final Map<ModelType, String?> apiKeys;
  final Map<ModelType, String?> modelNames;
  final bool? saveSuccess;

  const SettingsLoaded({
    required this.modelType,
    this.apiKeys = const {},
    this.modelNames = const {},
    this.saveSuccess,
  });

  @override
  List<Object?> get props => [modelType, apiKeys, modelNames, saveSuccess];

  String? getApiKey(ModelType type) => apiKeys[type];
  String? getModelName(ModelType type) => modelNames[type];

  SettingsLoaded copyWith({
    ModelType? modelType,
    Map<ModelType, String?>? apiKeys,
    Map<ModelType, String?>? modelNames,
    bool? saveSuccess,
  }) {
    return SettingsLoaded(
      modelType: modelType ?? this.modelType,
      apiKeys: apiKeys ?? this.apiKeys,
      modelNames: modelNames ?? this.modelNames,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  SettingsLoaded updateApiKey(ModelType type, String? apiKey) {
    final newApiKeys = Map<ModelType, String?>.from(apiKeys);
    newApiKeys[type] = apiKey;
    return copyWith(apiKeys: newApiKeys);
  }

  SettingsLoaded updateModelName(ModelType type, String? modelName) {
    final newModelNames = Map<ModelType, String?>.from(modelNames);
    newModelNames[type] = modelName;
    return copyWith(modelNames: newModelNames);
  }

  static SettingsLoaded empty() {
    return const SettingsLoaded(
      modelType: ModelType.local,
      apiKeys: {},
      modelNames: {},
      saveSuccess: null,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
