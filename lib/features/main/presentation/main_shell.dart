import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/community/presentation/community_page.dart';
import 'package:xyz/features/inbox/presentation/inbox_page.dart';
import 'package:xyz/features/main/logic/main_bloc.dart';
import 'package:xyz/features/main/logic/main_event.dart';
import 'package:xyz/features/main/logic/main_state.dart';
import 'package:xyz/features/settings/presentation/profile_page.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Get.find<MainBloc>();
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          final index = state.currentIndex;

          final pages = const [
            CommunityPage(),
            Scaffold(),
            Scaffold(),
            InboxPage(),
            ProfilePage(),
          ];

          return Scaffold(
            body: IndexedStack(index: index, children: pages),
            bottomNavigationBar: NavigationBar(
              backgroundColor: AppColors.accent,
              selectedIndex: index,
              indicatorColor: AppColors.surface,
              onDestinationSelected: (i) => bloc.add(MainTabChanged(i)),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Community',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  label: 'Matches',
                ),
                NavigationDestination(
                  icon: Icon(Icons.ondemand_video_outlined),
                  label: 'Workshops',
                ),
                NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  label: 'Inbox',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
