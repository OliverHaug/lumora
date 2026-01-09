import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumora/core/providers/app_providers.dart';
import 'package:lumora/features/community/presentation/community_page.dart';
import 'package:lumora/features/community/tabs/following/logic/circle_event.dart';
import 'package:lumora/features/inbox/presentation/chat_page.dart';
import 'package:lumora/features/inbox/presentation/inbox_page.dart';
import 'package:lumora/features/settings/presentation/settings_page.dart';
import 'package:lumora/features/start/presentation/start_page.dart';
import 'package:lumora/features/auth/presentation/login_page.dart';
import 'package:lumora/features/auth/presentation/register_page.dart';
import 'package:lumora/features/main/presentation/main_shell.dart';
import 'package:lumora/features/community/tabs/posts/presentation/post_detail.dart';
import 'dart:async';

final routerProvider = Provider<GoRouter>((ref) {
  final sessionAsync = ref.watch(sessionProvider);
  final session =
      sessionAsync.asData?.value ?? ref.read(currentSessionProvider);

  final authChanges = Supabase.instance.client.auth.onAuthStateChange;

  return GoRouter(
    initialLocation: '/start',
    refreshListenable: _GoRouterRefreshStream(authChanges),
    redirect: (context, state) {
      final loggedIn = session != null;
      final loc = state.matchedLocation;
      final goingToAuth =
          loc == '/start' || loc == '/login' || loc == '/register';

      if (loggedIn && goingToAuth) return '/community/posts';

      if (!loggedIn && loc.startsWith('/community')) {
        return '/start';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/community/posts'),
      GoRoute(path: '/community', redirect: (_, __) => '/community/posts'),
      GoRoute(path: '/start', builder: (_, __) => const StartPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community/posts',
                builder: (_, __) =>
                    const CommunityPage(initialTab: CommunityTab.posts),
                routes: [
                  GoRoute(
                    path: 'tweet/:postId',
                    builder: (_, state) =>
                        PostDetail(postId: state.pathParameters['postId']!),
                  ),
                ],
              ),
              GoRoute(
                path: '/community/following',
                builder: (_, state) {
                  final tab = state.uri.queryParameters['tab'];
                  final mode = (tab == 'discover')
                      ? CircleTabMode.discover
                      : CircleTabMode.following;

                  return CommunityPage(
                    initialTab: CommunityTab.following,
                    followingMode: mode,
                  );
                },
              ),
              GoRoute(
                path: '/community/profile',
                builder: (_, __) =>
                    const CommunityPage(initialTab: CommunityTab.profile),
              ),
              GoRoute(
                path: '/community/profile/:userId',
                builder: (_, state) => CommunityPage(
                  initialTab: CommunityTab.profile,
                  userId: state.pathParameters['userId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/matches', builder: (_, __) => const Scaffold()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/workshops', builder: (_, __) => const Scaffold()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (_, __) => const InboxPage(),
                routes: [
                  GoRoute(
                    path: 'chat/:conversationId',
                    builder: (_, state) {
                      final conversationId =
                          state.pathParameters['conversationId']!;

                      /// ✅ Query-Parameter (optional)
                      final qp = state.uri.queryParameters;

                      return ChatPage(
                        conversationId: conversationId,
                        peerName: qp['peer_name'],
                        peerAvatarUrl: qp['peer_avatar_url'],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
