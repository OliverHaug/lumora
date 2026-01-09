import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
import 'package:xyz/core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
=======
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/main/widgets/inbox_badge_icon.dart';

class MainShell extends ConsumerWidget {
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
=======
  Widget build(BuildContext context, ref) {
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.accent,
        selectedIndex: navigationShell.currentIndex,
        indicatorColor: AppColors.surface,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
<<<<<<< HEAD
        destinations: const [
=======
        destinations: [
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
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
<<<<<<< HEAD
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            label: 'Inbox',
          ),
=======
          NavigationDestination(icon: InboxBadgeIcon(), label: 'Inbox'),
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
