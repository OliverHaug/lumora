import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumora/features/community/tabs/posts/data/post_models.dart';
import 'package:lumora/features/community/tabs/posts/data/post_repository.dart';
import 'package:lumora/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:lumora/features/community/tabs/posts/logic/post/post_event.dart';
import 'package:lumora/features/community/tabs/posts/logic/post_edit/post_editor_state.dart';

class PostEditorCubit extends Cubit<PostEditorState> {
  final PostRepository _repo;
  final PostBloc _postBloc;
  final PostModel? _initialPost;

  PostEditorCubit({
    required PostRepository repo,
    required PostBloc postBloc,
    PostModel? initialPost,
  }) : _repo = repo,
       _postBloc = postBloc,
       _initialPost = initialPost,
       super(
         PostEditorState(
           text: initialPost?.content ?? '',
           controller: TextEditingController(text: initialPost?.content ?? ""),
           existingImageUrl: initialPost?.imageUrl,
           existingImagePath: initialPost?.imagePath,
           isEdit: initialPost != null,
         ),
       ) {
    state.controller.addListener(() => textChanged(state.controller.text));
  }

  void textChanged(String value) {
    emit(state.copyWith(text: value));
  }

  void imagePicked(XFile file) {
    emit(state.copyWith(imageFile: file));
  }

  Future<void> submit() async {
    final text = state.text.trim();
    if (text.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));

    try {
      String? imageUrl = state.existingImageUrl;
      String? imagePath = state.existingImagePath;

      if (state.imageFile != null) {
        final uploaded = await _repo.uploadPostImage(state.imageFile!);
        imageUrl = uploaded['url'];
        imagePath = uploaded['path'];
      }

      if (state.isEdit && _initialPost != null) {
        _postBloc.add(
          PostEditSubmitted(
            postId: _initialPost.id,
            content: text,
            imageUrl: imageUrl,
            imagePath: imagePath,
            removeImage: state.removeImage,
          ),
        );
      } else {
        _postBloc.add(
          PostCreated(content: text, imageUrl: imageUrl, imagePath: imagePath),
        );
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false));
      rethrow;
    }
  }

  void removeImagePressed() {
    emit(
      state.copyWith(
        imageFile: null,
        existingImageUrl: null,
        existingImagePath: null,
        removeImage: true,
      ),
    );
  }
}
