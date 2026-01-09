import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumora/features/community/tabs/profile/data/profile_repository.dart';
import 'package:lumora/features/community/tabs/profile/logic/profile_bloc.dart';

Future<void> showEditAvatarSheet(
  BuildContext context,
  ProfileRepository repo,
  ProfileBloc bloc,
) async {
  final picker = ImagePicker();

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Avatar',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: const Text(
                  'Pick from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                onPressed: () async {
                  final file = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1600,
                    imageQuality: 85,
                  );
                  if (file == null) return;

                  final signedUrl = await repo.uploadAvatar(file);
                  await repo.updateAvatarUrl(avatarUrl: signedUrl);

                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
