import 'package:flutter/material.dart';
import 'package:lumora/features/community/tabs/profile/data/profile_repository.dart';
import 'package:lumora/features/community/tabs/profile/logic/profile_bloc.dart';
import 'package:lumora/features/community/tabs/profile/logic/profile_event.dart';

Future<void> showEditBioSheet(
  BuildContext context, {
  required String initialBio,
  required ProfileRepository repo,
  required ProfileBloc bloc,
}) {
  final controller = TextEditingController(text: initialBio);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final bottom = MediaQuery.of(ctx).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Edit Bio',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            TextField(
              controller: controller,
              maxLines: 6,
              minLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write something about you...',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  await repo.updateBio(bio: text);
                  bloc.add(const ProfileRefreshed());
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
