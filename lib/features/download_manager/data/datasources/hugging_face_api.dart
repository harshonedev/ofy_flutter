import 'package:dio/dio.dart';
import 'package:llm_cpp_chat_app/core/error/exceptions.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/models/model_data.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/models/model_details_data.dart';
import 'package:logger/logger.dart';

abstract class HuggingFaceApi {
  // Calls the api to get a GGUF models
  // Throws a [ServerException] for all error codes
  Future<List<ModelData>> getGGUFModels();
  Future<ModelDetailsData> getModelDetails(String modelId);
}

class HuggingFaceApiImpl implements HuggingFaceApi {
  final Dio dio;

  HuggingFaceApiImpl({required this.dio});
  final Logger logger = Logger();

  final String baseUrl = 'https://huggingface.co/api/models';
  @override
  Future<List<ModelData>> getGGUFModels() async {
    try {
      final response = await dio.get("$baseUrl?search=gguf");
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = response.data;
        logger.d('GGUF Models: $jsonResponse');
        return jsonResponse
            //.where((model) => model['library_name'] == "gguf")
            .map((model) => ModelData.fromJson(model))
            .toList();
      } else {
        logger.e('Failed to load models: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load models: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.e('Error fetching GGUF models: $e');
      throw ServerException(message: 'Failed to load models: $e');
    }
  }

  @override
  Future<ModelDetailsData> getModelDetails(String modelId) async {
    try {
      final response = await dio.get("$baseUrl/$modelId");
      if (response.statusCode == 200) {
        logger.d('Model Details: ${response.data}');
        return ModelDetailsData.fromJson(response.data);
      } else {
        logger.e('Failed to load model details: ${response.statusCode}');

        throw ServerException(
          message: 'Failed to load model details: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.e('Error fetching model details: $e');
      throw ServerException(message: 'Failed to load model details: $e');
    }
  }
}
