import 'dart:async';
import '../entities/message.dart';

abstract class ModelServiceInterface {
  Stream<String> get responseStream;
  bool get isModelLoaded;

  Future<bool> loadModel(String modelPath);
  Future<void> cancelCurrentRequest();
  Future<void> sendPrompt(String prompt);
  String buildPrompt(List<Message> messages);
  void dispose();
}
