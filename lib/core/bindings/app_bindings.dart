import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/core/config/supabase_config.dart';
import 'package:xyz/core/session/session_controller.dart';
import 'package:xyz/features/auth/data/auth_repository.dart';
import 'package:xyz/features/auth/logic/login/login_bloc.dart';
import 'package:xyz/features/auth/logic/register/register_bloc.dart';
import 'package:xyz/features/community/logic/community_bloc.dart';
import 'package:xyz/features/community/tabs/posts/data/post_repository.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/main/logic/main_bloc.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() async {
    final client = SupabaseConfig.client;

    //global
    Get.put<SupabaseClient>(client, permanent: true);
    Get.put<SessionController>(SessionController(client), permanent: true);

    //auth
    Get.put<AuthRepository>(AuthRepository(client), permanent: true);
    Get.lazyPut(() => LoginBloc(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => RegisterBloc(Get.find<AuthRepository>()), fenix: true);

    //community
    Get.put<PostRepository>(PostRepository(client), permanent: true);
    Get.lazyPut(() => CommunityBloc());
    Get.lazyPut(() => MainBloc());
    Get.lazyPut(() => PostBloc(Get.find<PostRepository>()), fenix: true);
  }
}
