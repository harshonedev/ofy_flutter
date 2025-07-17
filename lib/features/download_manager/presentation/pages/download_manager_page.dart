import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:llm_cpp_chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/pages/model_list_page.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/widgets/download_button.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/bloc/model_picker_bloc.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/bloc/model_picker_event.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/bloc/model_picker_state.dart';

class DownloadManager extends StatefulWidget {
  const DownloadManager({super.key});

  @override
  State<DownloadManager> createState() => _DownloadManagerState();
}

class _DownloadManagerState extends State<DownloadManager> {
  final List<FileDetails> _recommendedModels = [
    const FileDetails(
      fileName: 'qwen2.5-1.5b-instruct-q3_k_m.gguf',
      fileSize: '881.63 MB',
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q3_k_m.gguf',
    ),
    const FileDetails(
      fileName: 'gemma-3-1b-it-Q6_K.gguf',
      fileSize: '1 GB',
      downloadUrl:
          'https://huggingface.co/unsloth/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q6_K.gguf',
    ),
    const FileDetails(
      fileName: 'Llama-3.2-3B-Instruct-Q2_K.gguf',
      fileSize: '1.3 GB',
      downloadUrl:
          'https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q2_K.gguf',
    ),
    const FileDetails(
      fileName: 'mistral-7b-instruct-v0.1.Q2_K.gguf',
      fileSize: '2.87 GB',
      downloadUrl:
          'https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/mistral-7b-instruct-v0.1.Q2_K.gguf',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load downloaded models when page is initialized
    BlocProvider.of<DownloadManagerBloc>(context)
      ..add(LoadActiveDownloadsEvent())
      ..add(LoadDownloadedModelsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Models'),
        scrolledUnderElevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: BlocListener<DownloadManagerBloc, DownloadManagerState>(
              listener: (context, state) {
                if (state is DownloadErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
                if (state is DownloadCompletedState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Download completed'),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                }

                if (state is DownloadStartedState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading...')),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Downloads Section
                  _buildActiveSectionHeader(context, 'Active Downloads'),
                  const SizedBox(height: 12),
                  _buildActiveDownloads(context),

                  const SizedBox(height: 32),

                  // Available Models Section
                  _buildAvailableModelsSection(context),

                  const SizedBox(height: 32),

                  _buildRecommendedModelsSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModelListPage(),
              settings: const RouteSettings(name: 'ModelListPage'),
            ),
          );
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        icon: const Icon(Icons.download_rounded),
        label: const Text('Download Models'),
      ),
    );
  }

  Widget _buildActiveSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.downloading_rounded, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDownloads(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<DownloadManagerBloc, DownloadManagerState>(
      listenWhen: (previous, current) {
        return (previous is DownloadingModelState &&
            current is DownloadingModelState &&
            previous.downloadModel.isPaused != current.downloadModel.isPaused);
      },
      listener: (context, state) {
        if (state is DownloadingModelState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.downloadModel.isPaused
                    ? 'Download paused'
                    : 'Download resumed',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return current is DownloadingModelState ||
            current is DownloadCompletedState ||
            current is DownloadErrorState ||
            current is InitialDownloadManagerState ||
            current is LoadingActiveDownloadsState;
      },
      builder: (context, state) {
        if (state is DownloadingModelState) {
          return _buildDownloadProgressCard(
            context: context,
            fileName: state.downloadModel.fileName,
            progress: state.downloadModel.progress.toInt(),
            task: state.downloadModel.task,
          );
        } else {
          // No active downloads
          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_done_rounded,
                    size: 32,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active downloads',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDownloadProgressCard({
    required BuildContext context,
    required String fileName,
    required int progress,
    required Task task,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final blocState = BlocProvider.of<DownloadManagerBloc>(context).state;
    final isPaused =
        blocState is DownloadingModelState
            ? blocState.downloadModel.isPaused
            : false;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPaused ? Icons.pause_rounded : Icons.downloading_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isPaused ? 'Paused' : 'Downloading...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular progress indicator with percentage
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated circular progress
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress / 100),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            backgroundColor: colorScheme.surfaceVariant,
                            color:
                                isPaused
                                    ? colorScheme.tertiary.withOpacity(0.8)
                                    : colorScheme.primary,
                            strokeWidth: 6,
                          );
                        },
                      ),
                      // Percentage text
                      Text(
                        '$progress%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isPaused
                                  ? colorScheme.tertiary
                                  : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress / 100),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: colorScheme.surfaceVariant,
                    color:
                        isPaused
                            ? colorScheme.tertiary.withOpacity(0.8)
                            : colorScheme.primary,
                    minHeight: 10,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Pause/Resume button
                FilledButton.tonal(
                  onPressed: () {
                    if (isPaused) {
                      // Resume download
                      context.read<DownloadManagerBloc>().add(
                        ResumeDownloadEvent(task),
                      );
                    } else {
                      // Pause download
                      context.read<DownloadManagerBloc>().add(
                        PauseDownloadEvent(task),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(isPaused ? 'Resume' : 'Pause'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Cancel button
                FilledButton.tonal(
                  onPressed: () {
                    // Cancel the download
                    context.read<DownloadManagerBloc>().add(
                      CancelDownloadEvent(task),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer.withOpacity(
                      0.6,
                    ),
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableModelsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Available Models'),
        const SizedBox(height: 12),
        _buildCompletedDownloads(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.folder_rounded, size: 20, color: colorScheme.tertiary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          onPressed: () {
            // Refresh local models list
            context.read<DownloadManagerBloc>().add(
              LoadDownloadedModelsEvent(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedModelsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.star_rounded,
                color: colorScheme.onTertiaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Recommended Models',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._recommendedModels.map((fileDetails) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12.0),
            color: colorScheme.surfaceVariant.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileDetails.fileName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'File size: ${fileDetails.fileSize}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  DownloadButton(
                    fileName: fileDetails.fileName,
                    onPressed: () {
                      BlocProvider.of<DownloadManagerBloc>(context).add(
                        DownloadModelEvent(
                          fileDetails.fileName,
                          fileDetails.downloadUrl,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCompletedDownloads(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    int selectedModelIndex = -1;

    return BlocListener<ModelPickerBloc, ModelPickerState>(
      listener: (context, state) {
        if (state is ModelPickerLoaded &&
            state.saveSuccess == true &&
            state.modelPath != null) {
          // Initialize Chat BLoC with selected model path
          context.read<ChatBloc>().add(
            InitializeModelEvent(modelPath: state.modelPath!),
          );
        }
      },
      child: BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
        buildWhen: (previous, current) {
          return current is LoadingDownloadedModelsState ||
              current is LoadedDownloadedModelsState;
        },
        builder: (context, state) {
          if (state is LoadingDownloadedModelsState) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (state is LoadedDownloadedModelsState &&
              state.modelFiles.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.modelFiles.length,
              itemBuilder: (context, index) {
                final model = state.modelFiles[index];
                return Card(
                  elevation: 0,
                  color: colorScheme.surfaceVariant.withOpacity(0.4),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () {
                      context.read<ModelPickerBloc>().add(
                        SaveModelPathEvent(modelPath: model.filePath),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Model selected'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      setState(() {
                        selectedModelIndex = index;
                      });
                    },
                    selected: selectedModelIndex == index,
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.model_training_rounded,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      model.fileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      model.fileSize,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      onPressed: () {
                        context.read<DownloadManagerBloc>().add(
                          RemoveModelEvent(model.taskId),
                        );
                        // Delete model functionality
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            // No downloaded models
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 32,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No downloaded models',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ModelListPage(),
                            settings: const RouteSettings(
                              name: 'ModelListPage',
                            ),
                          ),
                        );
                      },
                      child: const Text('Browse Models'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
