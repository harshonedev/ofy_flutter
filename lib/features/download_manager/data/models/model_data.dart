import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';

class ModelData extends Model {
  const ModelData({
    required super.id,
    required super.pipeline,
    required super.author,
    required super.files,
  });

  factory ModelData.fromJson(Map<String, dynamic> json) {
    return ModelData(
      id: json['id'],
      pipeline: json['pipeline_tag'],
      author: json['author'],
      files:
          json['siblings']
              ? (json['siblings'] as List<Map<String, String>>)
                  .where(
                    (file) =>
                        file['rfilename'] != null &&
                        file['rfilename']!.endsWith('.gguf'),
                  )
                  .map((file) => file['rfilename'] as String)
                  .toList()
              : null,
    );
  }

}
