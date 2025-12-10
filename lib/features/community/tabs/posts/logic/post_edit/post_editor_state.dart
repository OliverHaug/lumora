import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class PostEditorState extends Equatable {
  final String text;
  final XFile? imageFile;
  final String? existingImageUrl;
  final bool isSubmitting;
  final bool isEdit;

  const PostEditorState({
    this.text = '',
    this.imageFile,
    this.existingImageUrl,
    this.isSubmitting = false,
    this.isEdit = false,
  });

  PostEditorState copyWith({
    String? text,
    XFile? imageFile,
    String? existingImageUrl,
    bool? isSubmitting,
    bool? isEdit,
  }) {
    return PostEditorState(
      text: text ?? this.text,
      imageFile: imageFile ?? this.imageFile,
      existingImageUrl: existingImageUrl ?? this.existingImageUrl,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isEdit: isEdit ?? this.isEdit,
    );
  }

  @override
  List<Object?> get props => [
    text,
    imageFile,
    existingImageUrl,
    isSubmitting,
    isEdit,
  ];
}
