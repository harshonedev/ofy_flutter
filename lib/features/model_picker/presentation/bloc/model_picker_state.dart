import 'package:equatable/equatable.dart';

abstract class ModelPickerState extends Equatable {
  const ModelPickerState();

  @override
  List<Object?> get props => [];
}

class ModelPickerInitial extends ModelPickerState {}

class ModelPickerLoading extends ModelPickerState {}

class ModelPickerLoaded extends ModelPickerState {
  final String? modelPath;
  final bool? saveSuccess;
  final bool isModelSelected;

  const ModelPickerLoaded({
    this.modelPath,
    this.saveSuccess,
    this.isModelSelected = false,
  });

  @override
  List<Object?> get props => [modelPath, saveSuccess, isModelSelected];

  ModelPickerLoaded copyWith({
    String? modelPath,
    bool? saveSuccess,
    bool? isModelSelected,
  }) {
    return ModelPickerLoaded(
      modelPath: modelPath ?? this.modelPath,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      isModelSelected: isModelSelected ?? this.isModelSelected,
    );
  }
}

class ModelPickerError extends ModelPickerState {
  final String message;

  const ModelPickerError({required this.message});

  @override
  List<Object?> get props => [message];
}
