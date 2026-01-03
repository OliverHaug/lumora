import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_card.dart';
import 'package:xyz/features/community/tabs/profile/presentation/widgets/edit/edit_avatar_sheet.dart';
import 'package:xyz/features/community/tabs/profile/presentation/widgets/edit/edit_bio_sheet.dart';
import 'package:xyz/features/community/tabs/profile/presentation/widgets/edit/edit_gallery_sheet.dart';
import 'package:xyz/features/community/tabs/profile/presentation/widgets/profile_moments_slider.dart';
import 'package:xyz/features/community/tabs/profile/presentation/widgets/profile_header.dart';
import 'package:xyz/features/community/tabs/profile/presentation/widgets/profile_healing_accordion.dart';
import 'package:xyz/features/community/tabs/profile/presentation/widgets/profile_section_title.dart';
import '../logic/profile_bloc.dart';
import '../logic/profile_event.dart';
import '../logic/profile_state.dart';

class ProfileTab extends StatelessWidget {
  final String? userIdToShow; // null => me

  const ProfileTab({super.key, this.userIdToShow});

  @override
  Widget build(BuildContext context) {
    final bloc = Get.find<ProfileBloc>();

    // Wenn userId wechselt: neu laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bloc.state.viewingUserId != userIdToShow) {
        bloc.add(ProfileUserChanged(userId: userIdToShow));
      }
    });

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: const Color(0xfff4f2f0),
        appBar: AppBar(
          backgroundColor: const Color(0xfff4f2f0),
          elevation: 0,
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.status == ProfileStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == ProfileStatus.failure) {
                return Center(child: Text(state.error ?? 'Error'));
              }
              final user = state.user;
              if (user == null) return const SizedBox();

              return RefreshIndicator(
                onRefresh: () async => context.read<ProfileBloc>().add(
                  ProfileRefreshed(userId: user.id),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    ProfileHeader(
                      user: user,
                      isMe: state.isMe,
                      onEditAvatar: state.isMe
                          ? () => showEditAvatarSheet(context)
                          : null,
                      onConnect: state.isMe
                          ? null
                          : () {
                              // später: DM / Connect Flow
                            },
                    ),
                    const SizedBox(height: 14),

                    // About / Bio
                    ProfileSectionTitle(
                      title: 'About Me',
                      trailing: state.isMe
                          ? TextButton(
                              onPressed: () => showEditBioSheet(
                                context,
                                initialBio: user.bio ?? '',
                              ),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (user.bio?.trim().isNotEmpty ?? false)
                          ? user.bio!.trim()
                          : 'No bio yet.',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: .65),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // My Healing Philosophy (Accordion Card)
                    ProfileHealingAccordion(
                      isMe: state.isMe,
                      items: state.healing,
                    ),

                    const SizedBox(height: 26),

                    // Moments (horizontal slider)
                    Row(
                      children: [
                        const Text(
                          'Moments',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // optional: View All (später)
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProfileMomentsSlider(
                      urls: state.galleryUrls,
                      isMe: state.isMe,
                      onEdit: state.isMe
                          ? () => showEditGallerySheet(context)
                          : null,
                    ),

                    const SizedBox(height: 26),

                    // Recent Thoughts (eigene Posts / fremde Posts)
                    ProfileSectionTitle(
                      title: 'Recent Thoughts',
                      trailing: null,
                    ),
                    const SizedBox(height: 10),
                    if (state.posts.isEmpty)
                      const Text('No posts yet.')
                    else
                      ...state.posts.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PostCard(
                            post: p,
                            onLike:
                                () {}, // optional später: an PostBloc hooken
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
