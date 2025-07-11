import 'dart:io';

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
  Future<int?> getFileSize(String fileUrl);
}

class HuggingFaceApiImpl implements HuggingFaceApi {
  final Dio dio;

  HuggingFaceApiImpl({required this.dio});
  final Logger logger = Logger();

  static const String baseUrl = 'https://huggingface.co';
  @override
  Future<List<ModelData>> getGGUFModels() async {
    try {
      final response = await dio.get("$baseUrl/api/models?search=gguf");
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = response.data;
        logger.d('GGUF Models: $jsonResponse');
        return jsonResponse
            .where(
              (model) =>
                  model['private'] == false &&
                  model['pipeline_tag'] == 'text-generation',
            )
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
      final response = await dio.get("$baseUrl/api/models/$modelId");
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

  @override
  Future<int?> getFileSize(String fileUrl) async {
    try {
      final response = await dio.head(fileUrl);
      if (response.statusCode == 200) {
        final contentLength = response.headers.value(
          HttpHeaders.contentLengthHeader,
        );
        if (contentLength != null) {
          logger.d('File Size: $contentLength');
          return int.tryParse(contentLength);
        } else {
          logger.e('Content-Length header is missing');
          return null;
        }
      } else {
        throw ServerException(
          message: 'Failed to get file size: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to get file size: $e');
    }
  }
}
