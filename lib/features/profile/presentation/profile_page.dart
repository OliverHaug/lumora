import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz/features/profile/logic/profile_bloc.dart';
import 'package:xyz/features/profile/logic/profile_event.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Get.find<ProfileBloc>().add(Logout()),
          child: Text("Log out"),
        ),
      ),
    );
  }
}
