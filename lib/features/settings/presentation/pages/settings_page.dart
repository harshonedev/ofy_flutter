// filepath: /home/harsh/FlutterProjects/llm_cpp_chat_app-1/lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_type.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(GetSettingsEvent());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.settingsTitle)),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            if (state.apiKey != null && _apiKeyController.text.isEmpty) {
              _apiKeyController.text = state.apiKey!;
            }

            if (state.saveSuccess == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppConstants.apiKeySavedMessage)),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is SettingsInitial || state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is SettingsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model Type Selection
                  const Text(
                    AppConstants.modelSelectionTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text(AppConstants.localModelLabel),
                    leading: Radio<ModelType>(
                      value: ModelType.local,
                      groupValue: state.modelType,
                      onChanged: (ModelType? value) {
                        if (value != null) {
                          context.read<SettingsBloc>().add(
                            SaveModelTypeEvent(modelType: value),
                          );
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(AppConstants.openAiModelLabel),
                    leading: Radio<ModelType>(
                      value: ModelType.openAi,
                      groupValue: state.modelType,
                      onChanged: (ModelType? value) {
                        if (value != null) {
                          context.read<SettingsBloc>().add(
                            SaveModelTypeEvent(modelType: value),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OpenAI Settings
                  if (state.modelType == ModelType.openAi) ...[
                    const Text(
                      AppConstants.openAiSettingsTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: AppConstants.apiKeyHint,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_apiKeyController.text.isNotEmpty) {
                          context.read<SettingsBloc>().add(
                            SaveApiKeyEvent(apiKey: _apiKeyController.text),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(AppConstants.apiKeyErrorMessage),
                            ),
                          );
                        }
                      },
                      child: const Text(AppConstants.saveButtonText),
                    ),
                  ],

                  // Local Model Settings
                  if (state.modelType == ModelType.local) ...[
                    const Text(
                      AppConstants.localModelSettingsTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Local model settings will be configured when you select a model file.',
                    ),
                  ],
                ],
              ),
            );
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
