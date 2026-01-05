import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xyz/core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
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
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
