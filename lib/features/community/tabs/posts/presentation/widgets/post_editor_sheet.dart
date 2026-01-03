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

class PostEditorBottomSheet extends StatelessWidget {
  final TextEditingController textController;

  const PostEditorBottomSheet({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    final imagePicker = ImagePicker();

    return BlocBuilder<PostEditorCubit, PostEditorState>(
      builder: (context, state) {
        final isEdit = state.isEdit;

        Future<void> pickImage() async {
          final img = await imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1600,
            imageQuality: 85,
          );
          if (img == null) return;

          if (!context.mounted) return;

          context.read<PostEditorCubit>().imagePicked(img);
        }

        Future<void> submit() async {
          context.read<PostEditorCubit>().textChanged(
            textController.text.trim(),
          );

          try {
            await context.read<PostEditorCubit>().submit();
            if (context.mounted) Navigator.of(context).pop();
          } catch (e, st) {
            debugPrint('post editor error: $e');
            debugPrint('$st');
          }
        }

        Widget? imageWidget;
        if (state.imageFile != null) {
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(state.imageFile!.path),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        } else if (state.existingImageUrl != null) {
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              state.existingImageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isEdit ? 'Edit post' : 'Create post',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: state.isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => context
                        .read<PostEditorCubit>()
                        .textChanged(v.trimRight()),
                    onSubmitted: (_) => submit(),
                  ),
                  const SizedBox(height: 12),

                  if (imageWidget != null) ...[
                    imageWidget,
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
                              ? 'Bild ändern'
                              : 'Bild hinzufügen',
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: state.isSubmitting ? null : submit,
                        icon: state.isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send, size: 18),
                        label: Text(
                          state.isSubmitting
                              ? (isEdit ? 'Saving...' : 'Posting...')
                              : (isEdit ? 'Save' : 'Post'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
}) {
  final repo = Get.find<PostRepository>();
  final textController = TextEditingController(text: post?.content ?? '');

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return BlocProvider(
        create: (_) =>
            PostEditorCubit(repo: repo, postBloc: bloc, initialPost: post)
              ..textChanged(textController.text.trim()),
        child: Material(
          color: Theme.of(sheetContext).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: PostEditorBottomSheet(textController: textController),
        ),
      );
    },
  );
}
