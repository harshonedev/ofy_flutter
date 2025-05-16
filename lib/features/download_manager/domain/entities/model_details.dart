import 'package:equatable/equatable.dart';

class ModelDetails extends Equatable {
  final String id;
  final String? pipeline;
  final String? author;
  final List<FileDetails>? files;

  const ModelDetails({
    required this.id,
    required this.pipeline,
    required this.author,
    this.files,
  });

  ModelDetails copyWith({
    String? id,
    String? pipeline,
    String? author,
    List<FileDetails>? files,
  }) {
    return ModelDetails(
      id: id ?? this.id,
      pipeline: pipeline ?? this.pipeline,
      author: author ?? this.author,
      files: files ?? this.files,
    );
  }

  @override
  List<Object?> get props => [id, pipeline, author, files];
}

class FileDetails extends Equatable {
  final String fileName;
  final String? fileSize;
  final String downloadUrl;

  const FileDetails({
    required this.fileName,
    required this.downloadUrl,
    this.fileSize,
  });

  FileDetails copyWith({
    String? fileName,
    String? fileSize,
    String? downloadUrl,
  }) {
    return FileDetails(
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  List<Object?> get props => [fileName, fileSize, downloadUrl];
}
