import 'package:get/get.dart';
import 'package:xyz/core/router/splash_page.dart';
import 'package:xyz/features/auth/presentation/login_page.dart';
import 'package:xyz/features/auth/presentation/register_page.dart';
import 'package:xyz/features/community/tabs/posts/presentation/post_detail.dart';
import 'package:xyz/features/main/presentation/main_shell.dart';
import 'package:xyz/features/start/presentation/start_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/splash', page: () => const SplashPage()),
    GetPage(name: '/start', page: () => const StartPage()),
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/register', page: () => const RegisterPage()),
    GetPage(
      name: '/community',
      page: () => const MainShell(),
      children: [GetPage(name: '/tweet', page: () => const PostDetail())],
    ),
    //GetPage(name: '/inbox/chat', page: () => const ChatPage()),
  ];
}
