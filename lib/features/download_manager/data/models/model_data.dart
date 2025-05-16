import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';

class ModelData extends Model {
  const ModelData({
    required super.id,
    required super.pipeline,
  });

  factory ModelData.fromJson(Map<String, dynamic> json) {
    return ModelData(
      id: json['id'],
      pipeline: json['pipeline_tag'],
    );
  }
  
}
