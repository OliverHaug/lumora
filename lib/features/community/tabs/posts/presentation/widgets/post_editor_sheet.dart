import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';
import 'package:xyz/features/community/tabs/posts/data/post_repository.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post_edit/post_editor_cubit.dart';
import 'package:xyz/features/community/tabs/posts/logic/post_edit/post_editor_state.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/app_bottom_sheet_container.dart';

class PostEditorBottomSheet extends StatelessWidget {
  final PostModel? initialPost;

  const PostEditorBottomSheet({super.key, this.initialPost});

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    final cubit = context.read<PostEditorCubit>();

    Future<void> pickImage() async {
      final img = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (img != null) cubit.imagePicked(img);
    }

    Future<void> submit() async {
      try {
        await cubit.submit();
        if (context.mounted) Navigator.of(context).pop();
      } catch (_) {}
    }

    return BlocBuilder<PostEditorCubit, PostEditorState>(
      builder: (context, state) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        // Bild-Vorschau
        Widget? imagePreview;
        if (state.imageFile != null) {
          imagePreview = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(state.imageFile!.path),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        } else if (state.existingImageUrl != null) {
          imagePreview = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              state.existingImageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    state.isEdit ? "Edit Post" : "Create Post",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 💡 Controller kommt aus dem BLoC → kein Reset bei rebuilds!
              TextField(
                controller: state.controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              if (imagePreview != null) ...[
                imagePreview,
                const SizedBox(height: 8),
              ],

              Row(
                children: [
                  TextButton.icon(
                    onPressed: state.isSubmitting ? null : pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      (state.imageFile != null ||
                              state.existingImageUrl != null)
                          ? "Bild ändern"
                          : "Bild hinzufügen",
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: state.isSubmitting ? null : submit,
                    icon: state.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      state.isSubmitting
                          ? (state.isEdit ? "Saving..." : "Posting...")
                          : (state.isEdit ? "Save" : "Post"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showPostEditorSheet(
  BuildContext context, {
  PostModel? post,
  required PostBloc bloc,
}) async {
  final repo = Get.find<PostRepository>();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return BlocProvider(
        create: (_) =>
            PostEditorCubit(repo: repo, postBloc: bloc, initialPost: post),
        child: AppBottomSheetContainer(
          child: PostEditorBottomSheet(initialPost: post),
        ),
      );
    },
  );
}
