import 'package:dio/dio.dart';
import 'package:llm_cpp_chat_app/core/error/exceptions.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/models/model_data.dart';

abstract class HuggingFaceApi {
  // Calls the api to get a GGUF models
  // Throws a [ServerException] for all error codes
  Future<List<ModelData>> getGGUFModels();
  Future<ModelData> getModelDetails(String modelId);
}

class HuggingFaceApiImpl implements HuggingFaceApi {
  final Dio dio;

  HuggingFaceApiImpl({required this.dio});

  final String baseUrl = 'https://huggingface.co/api/models';
  @override
  Future<List<ModelData>> getGGUFModels() async {
    try {
      final response = await dio.get("$baseUrl?search=gguf");
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = response.data;
        return jsonResponse
            .where((model) => model['library_name'] == 'gguf')
            .map((model) => ModelData.fromJson(model))
            .toList();
      } else {
        throw ServerException(message: 'Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to load models: $e');
    }
  }

  @override
  Future<ModelData> getModelDetails(String modelId) async {
    try {
      final response = await dio.get("$baseUrl/$modelId");
      if (response.statusCode == 200) {
        return ModelData.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to load model details: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to load model details: $e');
    }
  }
}
