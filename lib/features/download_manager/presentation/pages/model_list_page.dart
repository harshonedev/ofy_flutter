import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_event.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_state.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/pages/model_details_page.dart';

class ModelListPage extends StatefulWidget {
  const ModelListPage({super.key});

  @override
  State<ModelListPage> createState() => _ModelListPageState();
}

class _ModelListPageState extends State<ModelListPage> {
  @override
  void initState() {
    super.initState();
    // Load models when page is initialized
    BlocProvider.of<DownloadManagerBloc>(context).add(LoadModelsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GGUF Models'), elevation: 0),
      body: BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
        builder: (context, state) {
          if (state is LoadingModelsState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LoadedModelsState) {
            return _buildModelList(context, state.models);
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
                      ).add(LoadModelsEvent());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Select a model to download'));
        },
      ),
    );
  }

  Widget _buildModelList(BuildContext context, List<Model> models) {
    if (models.isEmpty) {
      return const Center(child: Text('No models available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModelDetailsPage(modelId: model.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pipeline: ${model.pipeline}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 4),
              
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
