import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';

class ModelDetailsData extends ModelDetails {
  const ModelDetailsData({
    required super.id,
    required super.pipeline,
    required super.author,
    super.files,
  });

    factory ModelDetailsData.fromJson(Map<String, dynamic> json) {
    final siblings = json['siblings'] as List<dynamic>?;
    return ModelDetailsData(
      id: json['id'],
      pipeline: json['pipeline_tag'],
      author: json['author'],
      files: siblings != null 
          ? siblings.where((sibling) => sibling['rfilename'] != null && sibling['rfilename']!.endsWith('.gguf'))
              .map((sibling) => sibling['rfilename'] as String)
              .toList()
          : [],
    );
  }
}
