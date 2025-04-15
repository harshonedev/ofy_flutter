import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/model_type.dart';
import '../../../../core/utils/model_utils.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../settings/data/repositories/settings_repository.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../data/repositories/model_repository.dart';
import '../widgets/model_card.dart';

class ModelPickerPage extends StatefulWidget {
  const ModelPickerPage({super.key});

  @override
  State<ModelPickerPage> createState() => _ModelPickerPageState();
}

class _ModelPickerPageState extends State<ModelPickerPage> {
  String? _selectedModelPath;
  bool _isLoading = false;
  List<String> _recentModels = [];
  final ModelRepository _modelRepository = ModelRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  ModelType _modelType = ModelType.local;

  @override
  void initState() {
    super.initState();
    _loadRecentModels();
    _loadModelTypePreference();
  }

  Future<void> _loadModelTypePreference() async {
    final modelType = await _settingsRepository.getModelTypePreference();
    setState(() {
      _modelType = modelType;
    });

    // If OpenAI is selected and has API key, navigate directly to chat
    if (_modelType == ModelType.openAi) {
      _checkOpenAiAndNavigate();
    }
  }

  Future<void> _checkOpenAiAndNavigate() async {
    final apiKey = await _settingsRepository.getOpenAiApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      if (!mounted) return;

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final success = await chatProvider.switchToOpenAI();

      if (success && mounted) {
        // Navigate to chat screen directly
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      }
    }
  }

  Future<void> _loadRecentModels() async {
    try {
      final recentModels = await _modelRepository.getRecentModels();
      setState(() {
        _recentModels = recentModels;
      });
    } catch (e) {
      // Handle error loading recent models
      debugPrint('Error loading recent models: $e');
    }
  }

  Future<void> _pickModelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        if (ModelUtils.isValidModelFile(filePath)) {
          setState(() {
            _selectedModelPath = filePath;
          });

          // Save to recent models
          await _modelRepository.saveRecentModel(filePath);

          // Reload recent models
          await _loadRecentModels();
        } else {
          if (!mounted) return;
          _showErrorSnackBar('Invalid model file. Please select a GGUF file.');
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error picking file: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _navigateToChatPage() async {
    if (_selectedModelPath == null) {
      _showErrorSnackBar('Please select a model file first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final success = await chatProvider.loadModel(_selectedModelPath!);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatPage()),
      );
    } else {
      _showErrorSnackBar('Failed to load model. Please try another file.');
    }
  }

  Future<void> _navigateToOpenAI() async {
    final apiKey = await _settingsRepository.getOpenAiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      if (!mounted) return;

      // No API key, show settings page first
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final success = await chatProvider.switchToOpenAI();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatPage()),
      );
    } else {
      _showErrorSnackBar(
        'Failed to connect to OpenAI. Please check your API key in settings.',
      );
    }
  }

  void _selectModel(String modelPath) {
    setState(() {
      _selectedModelPath = modelPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      AppConstants.modelLoadingMessage,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppConstants.welcomeMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  // Model choice cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Local model card
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickModelFile,
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Icon(Icons.phone_android, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppConstants.localModelLabel,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Use local GGUF models',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: _pickModelFile,
                                      icon: const Icon(Icons.file_open),
                                      label: const Text('Browse'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(36),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // OpenAI model card
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToOpenAI,
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Icon(Icons.cloud, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppConstants.openAiModelLabel,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Use cloud-based OpenAI models',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: _navigateToOpenAI,
                                      icon: const Icon(Icons.api),
                                      label: const Text('Connect'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(36),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recent models section
                  if (_recentModels.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.history),
                          const SizedBox(width: 8),
                          Text(
                            'Recent Models',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recentModels.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final modelPath = _recentModels[index];
                          final isSelected = modelPath == _selectedModelPath;

                          return ModelCard(
                            modelPath: modelPath,
                            isSelected: isSelected,
                            onTap: () => _selectModel(modelPath),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No recent local models found.\nPlease select a model file or use OpenAI.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      floatingActionButton:
          _selectedModelPath != null
              ? FloatingActionButton.extended(
                onPressed: _navigateToChatPage,
                icon: const Icon(Icons.chat),
                label: const Text('Start Chat'),
              )
              : null,
    );
  }
}
