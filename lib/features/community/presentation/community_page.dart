import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumora/core/theme/app_colors.dart';
import 'package:lumora/features/community/tabs/following/logic/circle_event.dart';
import 'package:lumora/features/community/tabs/following/presentation/following_tab.dart';
import 'package:lumora/features/community/tabs/posts/presentation/post_tab.dart';
import 'package:lumora/features/community/tabs/profile/presentation/profile_tab.dart';

enum CommunityTab { posts, following, profile }

class CommunityPage extends ConsumerWidget {
  const CommunityPage({
    super.key,
    required this.initialTab,
    this.userId,
    this.followingMode,
  });

  final CommunityTab initialTab;
  final String? userId;
  final CircleTabMode? followingMode;

  int get index => switch (initialTab) {
    CommunityTab.posts => 0,
    CommunityTab.following => 1,
    CommunityTab.profile => 2,
  };

  void _go(BuildContext context, CommunityTab tab) {
    switch (tab) {
      case CommunityTab.posts:
        context.go('/community/posts');
        return;
      case CommunityTab.following:
        context.go('/community/following');
        return;
      case CommunityTab.profile:
        context.go('/community/profile');
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = [
      PostTab(),
      FollowingTab(initialMode: followingMode ?? CircleTabMode.following),
      ProfileTab(userIdToShow: userId),
    ];
    final labels = ['Posts', 'Following', 'Profile'];

    return SafeArea(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final segment = w / labels.length;

              return Column(
                children: [
                  Row(
                    children: List.generate(labels.length, (i) {
                      final selected = i == index;
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _go(context, CommunityTab.values[i]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: selected
                                      ? AppColors.black
                                      : AppColors.black.withValues(alpha: .6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    height: 4,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: Colors.black12),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          left: index * segment,
                          width: segment,
                          height: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1),
          Expanded(child: tabs[index]),
        ],
      ),
    );
  }
}
