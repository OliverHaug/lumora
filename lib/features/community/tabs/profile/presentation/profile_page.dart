import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:xyz/features/community/tabs/profile/logic/profile_bloc.dart';
import 'package:xyz/features/community/tabs/profile/logic/profile_event.dart';
import 'package:xyz/features/community/tabs/profile/presentation/profile_tab.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Get.arguments as String;
    final bloc = Get.find<ProfileBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!bloc.isClosed) bloc.add(ProfileStarted(userId: userId));
    });

    return BlocProvider.value(
      value: bloc,
      child: const ProfileTab(), // gleiche UI wiederverwenden
    );
  }
}
