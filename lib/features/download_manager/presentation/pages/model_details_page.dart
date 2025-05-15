import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.modelId), elevation: 0),
      body: BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
        builder: (context, state) {
          if (state is LoadingModelDetailsState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LoadedModelDetailsState) {
            return _buildModelDetails(context, state.model);
          } else if (state is ErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<DownloadManagerBloc>(
                        context,
                      ).add(LoadModelDetailsEvent(widget.modelId));
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is DownloadingModelState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: state.progress > 0 ? state.progress / 100 : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Downloading: ${state.progress}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      BlocProvider.of<DownloadManagerBloc>(
                        context,
                      ).add(CancelDownloadEvent());
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          } else if (state is DownloadCompletedState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Download Completed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Models'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Model details not available'));
        },
      ),
    );
  }

  Widget _buildModelDetails(BuildContext context, ModelDetails model) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model info card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Model Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _infoRow(context, 'ID', model.id),
                  _infoRow(context, 'Pipeline', model.pipeline ?? 'N/A'),
                  _infoRow(context, 'Author', model.author ?? 'Unknown'),
                  _infoRow(
                    context,
                    'Available Files',
                    model.files?.isNotEmpty ?? false
                        ? '${model.files!.length} GGUF files'
                        : 'No GGUF files',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Available GGUF files section
          if (model.files?.isNotEmpty ?? false) ...[
            Text(
              'Available GGUF Files',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: model.files!.length,
              itemBuilder: (context, index) {
                final fileName = model.files![index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        DownloadButton(
                          fileName: fileName,
                          onPressed: () {
                            // Trigger download
                            BlocProvider.of<DownloadManagerBloc>(
                              context,
                            ).add(DownloadModelEvent(fileName));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'No GGUF files available for this model',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
