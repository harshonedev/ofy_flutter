import 'package:equatable/equatable.dart';

abstract class ModelPickerEvent extends Equatable {
  const ModelPickerEvent();

  @override
  List<Object?> get props => [];
}

class GetModelPathEvent extends ModelPickerEvent {}

class SaveModelPathEvent extends ModelPickerEvent {
  final String modelPath;

  const SaveModelPathEvent({required this.modelPath});

  @override
  List<Object?> get props => [modelPath];
}

class SelectModelEvent extends ModelPickerEvent {}
