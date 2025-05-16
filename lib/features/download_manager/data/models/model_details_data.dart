import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/hugging_face_api.dart';
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
    final List<FileDetails> files =
        siblings != null
            ? siblings
                .where(
                  (sibling) =>
                      sibling['rfilename'] != null &&
                      sibling['rfilename']!.endsWith('.gguf'),
                )
                .map(
                  (sibling) => FileDetails(
                    fileName: sibling['rfilename'] as String,
                    downloadUrl:
                        "${HuggingFaceApiImpl.baseUrl}/${json['id']}/resolve/main/${sibling['rfilename']}",
                  ),
                )
                .toList()
            : [];
    return ModelDetailsData(
      id: json['id'],
      pipeline: json['pipeline_tag'],
      author: json['author'],
      files: files,
    );
  }

  ModelDetailsData copyWith({
    String? id,
    String? pipeline,
    String? author,
    List<FileDetails>? files,
  }) {
    return ModelDetailsData(
      id: id ?? this.id,
      pipeline: pipeline ?? this.pipeline,
      author: author ?? this.author,
      files: files ?? this.files,
    );
  }
}
