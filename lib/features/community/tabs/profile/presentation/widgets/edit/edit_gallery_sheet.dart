import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xyz/features/community/tabs/profile/data/profile_repository.dart';
import 'package:xyz/features/community/tabs/profile/logic/profile_bloc.dart';
import 'package:xyz/features/community/tabs/profile/logic/profile_event.dart';

Future<void> showEditGallerySheet(
  BuildContext context,
  ProfileBloc bloc,
  ProfileRepository repo,
) {
  final picker = ImagePicker();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final state = bloc.state;
      final urls = state.galleryUrls;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Edit Gallery',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Photo',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                onPressed: () async {
                  final file = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1600,
                    imageQuality: 85,
                  );
                  if (file == null) return;

                  final signedUrl = await repo.uploadGalleryImage(file);
                  await repo.addGalleryPhoto(
                    imagePath: signedUrl['path']!,
                    imageUrl: signedUrl['url']!,
                  );

                  bloc.add(const ProfileRefreshed());
                },
              ),
            ),

            const SizedBox(height: 12),

            if (urls.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text('No gallery photos yet.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: urls.length,
                  itemBuilder: (_, i) {
                    final url = urls[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          url,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text('Photo ${i + 1}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await repo.deleteGalleryPhoto(imageUrl: url);
                          bloc.add(const ProfileRefreshed());
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}
