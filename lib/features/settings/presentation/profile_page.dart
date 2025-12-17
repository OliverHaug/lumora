import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz/features/settings/logic/settings_bloc.dart';
import 'package:xyz/features/settings/logic/settings_event.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Get.find<SettingsBloc>().add(Logout()),
          child: Text("Log out"),
        ),
      ),
    );
  }
}
