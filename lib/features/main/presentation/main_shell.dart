import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumora/core/theme/app_colors.dart';
import 'package:lumora/features/main/widgets/inbox_badge_icon.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, ref) {
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
        destinations: [
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
          NavigationDestination(icon: InboxBadgeIcon(), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
