import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

import '../../../../core/constants/app_constants.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../bloc/model_picker_bloc.dart';
import '../bloc/model_picker_event.dart';
import '../bloc/model_picker_state.dart';

class ModelPickerPage extends StatelessWidget {
  const ModelPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Model')),
      body: BlocConsumer<ModelPickerBloc, ModelPickerState>(
        listener: (context, state) {
          if (state is ModelPickerLoaded &&
              state.saveSuccess == true &&
              state.modelPath != null) {
            // Initialize Chat BLoC with selected model path
            context.read<ChatBloc>().initializeModelPath(state.modelPath!);

            // Navigate to chat page when model is successfully selected
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
          }
        },
        builder: (context, state) {
          if (state is ModelPickerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ModelPickerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ModelPickerBloc>().add(SelectModelEvent());
                    },
                    child: const Text(AppConstants.pickModelButtonText),
                  ),
                ],
              ),
            );
          } else if (state is ModelPickerLoaded && state.modelPath != null) {
            final modelName = path.basename(state.modelPath!);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isModelSelected) ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 20),
                  const Text('Model Selected:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      modelName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Size: ${_getFileSize(state.modelPath!)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ChatPage(),
                        ),
                      );
                    },
                    child: const Text('Continue to Chat'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      context.read<ModelPickerBloc>().add(SelectModelEvent());
                    },
                    child: const Text('Choose Another Model'),
                  ),
                ],
              ],
            );
          } else {
            // Default state or ModelPickerInitial
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.model_training,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please select a GGUF model file',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ModelPickerBloc>().add(SelectModelEvent());
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text(AppConstants.pickModelButtonText),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String _getFileSize(String filePath) {
    final file = File(filePath);
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }
}
