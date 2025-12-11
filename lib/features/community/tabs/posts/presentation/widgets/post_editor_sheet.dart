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

enum PostEditorMode { create, edit }

class PostEditorBottomSheet extends StatelessWidget {
  final PostModel? initialPost;

  PostEditorBottomSheet({super.key, this.initialPost})
    : _textController = TextEditingController(text: initialPost?.content ?? '');

  final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    final imagePicker = ImagePicker();

    return BlocBuilder<PostEditorCubit, PostEditorState>(
      builder: (context, state) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        final isEdit = state.isEdit;

        Future<void> pickImage() async {
          final img = await imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1600,
            imageQuality: 85,
          );
          if (img == null) return;
          context.read<PostEditorCubit>().imagePicked(img); // 👈 direkt XFile
        }

        Future<void> submit() async {
          context.read<PostEditorCubit>().textChanged(_textController.text);
          try {
            await context.read<PostEditorCubit>().submit();
            if (context.mounted) Navigator.of(context).pop();
          } catch (_) {
            // optional: Fehler anzeigen
          }
        }

        // Bild-Preview
        Widget? imageWidget;
        if (state.imageFile != null) {
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(state.imageFile!.path), // 👈 XFile.path
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

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottom + 16,
          ),
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
                controller: _textController,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => Get.find<PostEditorCubit>().textChanged(v),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return BlocProvider(
        create: (_) =>
            PostEditorCubit(repo: repo, postBloc: bloc, initialPost: post),
        child: PostEditorBottomSheet(initialPost: post),
      );
    },
  );
}
