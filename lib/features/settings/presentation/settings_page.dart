import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xyz/core/providers/di_providers.dart';
import 'package:xyz/features/settings/logic/settings_event.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => ref.watch(settingsBlocProvider).add(Logout()),
          child: Text("Log out"),
        ),
      ),
    );
  }
}
