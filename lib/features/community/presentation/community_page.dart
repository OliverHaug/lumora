import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/instance_manager.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/community/logic/community_bloc.dart';
import 'package:xyz/features/community/logic/community_event.dart';
import 'package:xyz/features/community/logic/community_state.dart';
import 'package:xyz/features/community/tabs/following/presentation/following_tab.dart';
import 'package:xyz/features/community/tabs/posts/presentation/post_tab.dart';
import 'package:xyz/features/community/tabs/profile/presentation/profile_tab.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final communityBloc = Get.find<CommunityBloc>();

    return BlocProvider.value(
      value: communityBloc,
      child: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          final index = state.tabIndex;

          final tabs = [
            PostTab(),
            FollowingTab(),
            ProfileTab(userIdToShow: state.profileUserIdToShow),
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
                                onTap: () =>
                                    communityBloc.add(CommunityTabChanged(i)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                            : AppColors.black.withOpacity(.6),
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
        },
      ),
    );
  }
}
