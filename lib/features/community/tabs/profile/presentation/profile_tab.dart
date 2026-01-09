import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xyz/core/providers/di_providers.dart';
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

class ProfileTab extends ConsumerStatefulWidget {
  final String? userIdToShow;
  const ProfileTab({super.key, this.userIdToShow});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  String? _lastUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bloc = ref.read(profileBlocProvider);
    final repo = ref.read(profileRepositoryProvider);

    final targetUserId = widget.userIdToShow ?? repo.currentUserId;

    if (_lastUserId != targetUserId) {
      _lastUserId = targetUserId;
      bloc.add(ProfileUserChanged(userId: widget.userIdToShow));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ref.watch(profileBlocProvider);
    final repo = ref.watch(profileRepositoryProvider);

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
                  ProfileRefreshed(userId: state.viewingUserId),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    ProfileHeader(
                      user: user,
                      isMe: state.isMe,
                      onEditAvatar: state.isMe
                          ? () => showEditAvatarSheet(context, repo, bloc)
                          : null,
                      onConnect: state.isMe
                          ? null
                          : () async {
                              final inboxRepo = ref.read(
                                inboxRepositoryProvider,
                              );

                              final conversationId = await inboxRepo
                                  .getOrCreateDirectConnversation(user.id);

                              if (!context.mounted) return;

                              context.go('/inbox/chat/$conversationId');
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
                                repo: repo,
                                bloc: bloc,
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
                          ? () => showEditGallerySheet(context, bloc, repo)
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
