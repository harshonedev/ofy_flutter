import 'package:equatable/equatable.dart';

class FileSizeDetails extends Equatable {
  final String formattedSize;
  final int fileIndex;

  const FileSizeDetails({required this.formattedSize, required this.fileIndex});
  @override
  List<Object?> get props => [formattedSize, fileIndex];
}
