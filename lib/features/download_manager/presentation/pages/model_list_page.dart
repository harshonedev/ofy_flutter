import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/models_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/pages/model_details_page.dart';

class ModelListPage extends StatefulWidget {
  const ModelListPage({super.key});

  @override
  State<ModelListPage> createState() => _ModelListPageState();
}

class _ModelListPageState extends State<ModelListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    // Load models when page is initialized
    BlocProvider.of<ModelsBloc>(context).add(LoadModelsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GGUF Models'),
        scrolledUnderElevation: 2,
      ),
      body: BlocBuilder<ModelsBloc, ModelsState>(
        buildWhen: (previous, current) {
          // Only rebuild when the state changes to LoadingModelsState,
          // LoadedModelsState, or ErrorState
          return current is LoadingModelsState ||
              current is LoadedModelsState ||
              current is ModelsErrorState;
        },
        builder: (context, state) {
          if (state is LoadingModelsState) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (state is LoadedModelsState) {
            // Filter models based on search query
            final filteredModels =
                state.models.where((model) {
                  final query = _searchQuery.toLowerCase();
                  return model.id.toLowerCase().contains(query) ||
                      (model.pipeline?.toLowerCase().contains(query) ?? false);
                }).toList();
            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search models...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(child: _buildModelList(context, filteredModels)),
              ],
            );
          } else if (state is ModelsErrorState) {
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
                        BlocProvider.of<ModelsBloc>(
                          context,
                        ).add(LoadModelsEvent());
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.model_training_rounded,
                  size: 64,
                  color: colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a model to download',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed:
                      () => BlocProvider.of<ModelsBloc>(
                        context,
                      ).add(LoadModelsEvent()),
                  child: Text(
                    'Refresh',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModelList(BuildContext context, List<Model> models) {
    final colorScheme = Theme.of(context).colorScheme;

    if (models.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_rounded,
              size: 64,
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No models available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16.0),
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModelDetailsPage(modelId: model.id),
                  settings: const RouteSettings(name: 'ModelDetailsPage'),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.model_training_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.id,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          model.pipeline ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
