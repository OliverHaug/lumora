import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumora/core/providers/di_providers.dart';
import '../logic/circle_bloc.dart';
import '../logic/circle_event.dart';
import '../logic/circle_state.dart';
import 'widgets/circle_segmented_control.dart';
import 'widgets/circle_user_tile.dart';
import 'package:lumora/core/theme/app_colors.dart';

class FollowingTab extends ConsumerStatefulWidget {
  const FollowingTab({super.key, required this.initialMode});

  final CircleTabMode initialMode;

  @override
  ConsumerState<FollowingTab> createState() => _FollowingTabState();
}

class _FollowingTabState extends ConsumerState<FollowingTab> {
  @override
  void initState() {
    super.initState();

    final bloc = ref.read(circleBlocProvider);
    if (bloc.state.status == CircleStatus.initial) {
      bloc.add(const CircleStarted());
    }

    bloc.add(CircleTabChanged(widget.initialMode));
  }

  @override
  void didUpdateWidget(covariant FollowingTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialMode != widget.initialMode) {
      ref.read(circleBlocProvider).add(CircleTabChanged(widget.initialMode));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ref.watch(circleBlocProvider);

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: const Color(0xfff4f2f0),
        appBar: AppBar(
          backgroundColor: const Color(0xfff4f2f0),
          elevation: 0,
          title: const Text('My Circle'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<CircleBloc, CircleState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async => context.read<CircleBloc>().add(
                  const CircleRefreshRequested(),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    _SearchBar(
                      onChanged: (v) => context.read<CircleBloc>().add(
                        CircleSearchChanged(v),
                      ),
                      onFocusDiscover: () =>
                          context.go('/community/following?tab=discover'),
                    ),
                    const SizedBox(height: 12),

                    CircleSegmentedControl(
                      mode: state.mode,
                      onChanged: (m) {
                        final tab = (m == CircleTabMode.discover)
                            ? 'discover'
                            : 'following';
                        context.go('/community/following?tab=$tab');
                      },
                    ),
                    const SizedBox(height: 18),

                    if (state.status == CircleStatus.loading) ...[
                      const SizedBox(height: 30),
                      const Center(child: CircularProgressIndicator()),
                    ] else if (state.status == CircleStatus.failure) ...[
                      Text(state.error ?? 'Something went wrong'),
                    ] else ...[
                      if (state.mode == CircleTabMode.following)
                        _FollowingView(state: state)
                      else
                        _DiscoverView(state: state),
                    ],
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

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFocusDiscover;

  const _SearchBar({required this.onChanged, required this.onFocusDiscover});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      onTap: onFocusDiscover,
      decoration: InputDecoration(
        hintText: 'Find coaches, guides...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FollowingView extends StatelessWidget {
  final CircleState state;
  const _FollowingView({required this.state});

  @override
  Widget build(BuildContext context) {
    final following = state.following;
    final suggested = state.suggested;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR CONNECTIONS',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Colors.black.withValues(alpha: .55),
          ),
        ),
        const SizedBox(height: 10),

        if (following.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('You are not following anyone yet.'),
          )
        else
          ...following.map(
            (u) => CircleUserTile(
              circleUser: u,
              onToggleFollow: () =>
                  context.read<CircleBloc>().add(FollowToggled(u.user.id)),
            ),
          ),

        const SizedBox(height: 16),
        const Divider(height: 24),

        Row(
          children: [
            Text(
              'SUGGESTED FOR YOU',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Colors.black.withValues(alpha: .55),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/community/following?tab=discover'),
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...suggested
            .take(6)
            .map(
              (u) => CircleUserTile(
                circleUser: u,
                onToggleFollow: () =>
                    context.read<CircleBloc>().add(FollowToggled(u.user.id)),
              ),
            ),
      ],
    );
  }
}

class _DiscoverView extends StatelessWidget {
  final CircleState state;
  const _DiscoverView({required this.state});

  @override
  Widget build(BuildContext context) {
    final q = state.query.trim();
    final list = q.isEmpty ? state.suggested : state.discover;

    if (q.isNotEmpty && list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text('No results. Try another search.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.isEmpty ? 'DISCOVER' : 'RESULTS',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Colors.black.withValues(alpha: .55),
          ),
        ),
        const SizedBox(height: 10),
        ...list.map(
          (u) => CircleUserTile(
            circleUser: u,
            onToggleFollow: () =>
                context.read<CircleBloc>().add(FollowToggled(u.user.id)),
          ),
        ),
      ],
    );
  }
}
