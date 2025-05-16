import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/core/widgets/linear_typing_indicator.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/widgets/download_button.dart';

class ModelDetailsPage extends StatefulWidget {
  final String modelId;

  const ModelDetailsPage({super.key, required this.modelId});

  @override
  State<ModelDetailsPage> createState() => _ModelDetailsPageState();
}

class _ModelDetailsPageState extends State<ModelDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Load model details when page is initialized
    BlocProvider.of<DownloadManagerBloc>(
      context,
    ).add(LoadModelDetailsEvent(widget.modelId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.modelId), scrolledUnderElevation: 2),
      body: BlocConsumer<DownloadManagerBloc, DownloadManagerState>(
        listener: (context, state) {
          if (state is FileSizeErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          // Only rebuild when the state changes to LoadingModelDetailsState,
          // LoadedModelDetailsState, ErrorState, DownloadingModelState,
          // or DownloadCompletedState
          return current is LoadingModelDetailsState ||
              current is LoadedModelDetailsState ||
              current is ErrorState ||
              current is DownloadingModelState ||
              current is DownloadCompletedState;
        },
        builder: (context, state) {
          if (state is LoadingModelDetailsState) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (state is LoadedModelDetailsState) {
            return _buildModelDetails(context, state.model);
          } else if (state is ErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        BlocProvider.of<DownloadManagerBloc>(
                          context,
                        ).add(LoadModelDetailsEvent(widget.modelId));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is DownloadingModelState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value:
                                state.progress > 0
                                    ? state.progress / 100
                                    : null,
                            strokeWidth: 6,
                            backgroundColor: colorScheme.surfaceVariant,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${state.progress.toInt()}%',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Downloading Model',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait while we download the model file',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                      onPressed: () {
                        BlocProvider.of<DownloadManagerBloc>(
                          context,
                        ).add(CancelDownloadEvent());
                      },
                      icon: const Icon(Icons.cancel_rounded),
                      label: const Text('Cancel Download'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is DownloadCompletedState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Download Completed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your model is ready to use',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Models'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 64,
                  color: colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Model details not available',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModelDetails(BuildContext context, ModelDetails model) {
    List<FileDetails>? files = model.files;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model info card
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.model_training_rounded,
                        color: colorScheme.onTertiaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Model Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _infoRow(context, 'ID', model.id, Icons.tag_rounded),
                _infoRow(
                  context,
                  'Pipeline',
                  model.pipeline ?? 'N/A',
                  Icons.straighten_rounded,
                ),
                _infoRow(
                  context,
                  'Author',
                  model.author ?? 'Unknown',
                  Icons.person_rounded,
                ),
                _infoRow(
                  context,
                  'Available Files',
                  model.files?.isNotEmpty ?? false
                      ? '${model.files!.length} GGUF files'
                      : 'No GGUF files',
                  Icons.folder_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Available GGUF files section
          if (model.files?.isNotEmpty ?? false) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.file_present_rounded,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Available GGUF Files',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...files!.map((fileDetails) {
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
                            fileDetails.fileSize != null
                                ? Text(
                                  'File size: ${fileDetails.fileSize}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                )
                                : const LinearTypingIndicator(),
                          ],
                        ),
                      ),
                      DownloadButton(
                        fileName: fileDetails.fileName,
                        onPressed: () {
                          // Trigger download
                          BlocProvider.of<DownloadManagerBloc>(
                            context,
                          ).add(DownloadModelEvent(fileDetails.fileName));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 48,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No GGUF files available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This model does not have any available files to download',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
