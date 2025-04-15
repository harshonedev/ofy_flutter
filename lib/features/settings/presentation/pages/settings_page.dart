// filepath: /home/harsh/FlutterProjects/llm_cpp_chat_app-1/lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_type.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _openAiModelController = TextEditingController();
  final _settingsRepository = SettingsRepository();
  bool _isLoading = true;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _settingsRepository.getOpenAiApiKey() ?? '';
    final openAiModel = await _settingsRepository.getOpenAiModel();

    setState(() {
      _apiKeyController.text = apiKey;
      _openAiModelController.text = openAiModel;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _openAiModelController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _settingsRepository.saveOpenAiApiKey(_apiKeyController.text);
      await _settingsRepository.saveOpenAiModel(_openAiModelController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.apiKeySavedMessage),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setModelType(ModelType type) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (type == ModelType.openAi) {
      if (_apiKeyController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.openAiApiKeyMissing),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await chatProvider.switchToOpenAI();
    } else {
      await chatProvider.switchToLocalModel();
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppConstants.settingsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.settingsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model Type Selection
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.modelSelectionTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16.0),
                    Consumer<ChatProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          children: [
                            ListTile(
                              title: const Text(AppConstants.localModelLabel),
                              leading: Radio<ModelType>(
                                value: ModelType.local,
                                groupValue: provider.modelType,
                                onChanged: (ModelType? value) {
                                  if (value != null) {
                                    _setModelType(value);
                                  }
                                },
                              ),
                              subtitle: const Text(
                                'Process models locally on your device',
                              ),
                              dense: true,
                            ),
                            ListTile(
                              title: const Text(AppConstants.openAiModelLabel),
                              leading: Radio<ModelType>(
                                value: ModelType.openAi,
                                groupValue: provider.modelType,
                                onChanged: (ModelType? value) {
                                  if (value != null) {
                                    _setModelType(value);
                                  }
                                },
                              ),
                              subtitle: const Text(
                                'Use OpenAI API (requires internet and API key)',
                              ),
                              dense: true,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // OpenAI Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.openAiSettingsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16.0),
                      // API Key field
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          labelText: AppConstants.apiKeyHint,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureApiKey
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureApiKey = !_obscureApiKey;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureApiKey,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your OpenAI API key';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // OpenAI Model field
                      TextFormField(
                        controller: _openAiModelController,
                        decoration: const InputDecoration(
                          labelText: 'OpenAI Model',
                          border: OutlineInputBorder(),
                          hintText: 'gpt-3.5-turbo',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an OpenAI model name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveSettings,
                          child: const Text(AppConstants.saveButtonText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
