import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/model_utils.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRecentModels();
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

  void _selectModel(String modelPath) {
    setState(() {
      _selectedModelPath = modelPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
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

                  // Button to select model
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: _pickModelFile,
                      icon: const Icon(Icons.file_open),
                      label: const Text(AppConstants.pickModelButtonText),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
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
                        child: Text(
                          'No recent models found.\nPlease select a model file to begin.',
                          textAlign: TextAlign.center,
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
