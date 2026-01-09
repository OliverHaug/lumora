import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repos/Datasources
import 'package:xyz/features/auth/data/auth_repository.dart';
import 'package:xyz/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:xyz/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:xyz/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:xyz/features/community/tabs/following/data/circle_repository.dart';
import 'package:xyz/features/community/tabs/posts/data/post_repository.dart';
import 'package:xyz/features/community/tabs/profile/data/profile_repository.dart';
<<<<<<< HEAD
=======
import 'package:xyz/features/inbox/data/chat_repository.dart';
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
import 'package:xyz/features/inbox/data/inbox_repository.dart';
import 'package:xyz/features/inbox/data/local/inbox_local_datasource.dart';

// Blocs
import 'package:xyz/features/auth/logic/login/login_bloc.dart';
import 'package:xyz/features/auth/logic/register/register_bloc.dart';
import 'package:xyz/features/community/tabs/following/logic/circle_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/profile/logic/profile_bloc.dart';
<<<<<<< HEAD
import 'package:xyz/features/inbox/data/remote/inbox_remote_datasource.dart';
=======
import 'package:xyz/features/inbox/data/models/conversation_model.dart';
import 'package:xyz/features/inbox/data/remote/chat_local_datasource.dart';
import 'package:xyz/features/inbox/data/remote/chat_remote_datasource.dart';
import 'package:xyz/features/inbox/data/remote/inbox_remote_datasource.dart';
import 'package:xyz/features/inbox/logic/chat/chat_bloc.dart';
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
import 'package:xyz/features/inbox/logic/inbox_bloc.dart';
import 'package:xyz/features/settings/logic/settings_bloc.dart';

/// Supabase Client (single instance, initialized in main)
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// --------------------
/// Repositories
/// --------------------
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(supabaseClientProvider));
});

final circleRepositoryProvider = Provider<CircleRepository>((ref) {
  return CircleRepository(ref.watch(supabaseClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

final inboxLocalDataSourceProvider = Provider<InboxLocalDataSource>((ref) {
  return InboxLocalDataSource();
});

final inboxRemoteDataSourceProvider = Provider<InboxRemoteDataSource>((ref) {
  return InboxRemoteDataSource(ref.watch(supabaseClientProvider));
});

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return InboxRepository(
    ref.watch(inboxRemoteDataSourceProvider),
    ref.watch(inboxLocalDataSourceProvider),
  );
});

<<<<<<< HEAD
=======
final chatLocalDataSourceProvider = Provider<ChatLocalDataSource>((ref) {
  return ChatLocalDataSource();
});

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(ref.watch(supabaseClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(chatRemoteDataSourceProvider),
    ref.watch(chatLocalDataSourceProvider),
  );
});

>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
/// --------------------
/// Blocs (autoDispose + close)
/// --------------------
final loginBlocProvider = Provider.autoDispose<LoginBloc>((ref) {
  final bloc = LoginBloc(signIn: ref.watch(signInUseCaseProvider));
  ref.onDispose(bloc.close);
  return bloc;
});

final registerBlocProvider = Provider.autoDispose<RegisterBloc>((ref) {
  final bloc = RegisterBloc(signUp: ref.watch(signUpUseCaseProvider));
  ref.onDispose(bloc.close);
  return bloc;
});

final postBlocProvider = Provider.autoDispose<PostBloc>((ref) {
  final bloc = PostBloc(ref.watch(postRepositoryProvider));
  ref.onDispose(bloc.close);
  return bloc;
});

final circleBlocProvider = Provider.autoDispose<CircleBloc>((ref) {
  final bloc = CircleBloc(ref.watch(circleRepositoryProvider));
  ref.onDispose(bloc.close);
  return bloc;
});

final profileBlocProvider = Provider.autoDispose<ProfileBloc>((ref) {
  final bloc = ProfileBloc(
    ref.watch(profileRepositoryProvider),
    ref.watch(postRepositoryProvider),
  );
  ref.onDispose(bloc.close);
  return bloc;
});

final inboxBlocProvider = Provider.autoDispose<InboxBloc>((ref) {
  final bloc = InboxBloc(ref.watch(inboxRepositoryProvider));
  ref.onDispose(bloc.close);
  return bloc;
});

final settingsBlocProvider = Provider.autoDispose<SettingsBloc>((ref) {
  final bloc = SettingsBloc(ref.watch(authRepositoryProvider));
  ref.onDispose(bloc.close);
  return bloc;
});
<<<<<<< HEAD
=======

final chatBlocProvider = Provider.autoDispose
    .family<ChatBloc, ConversationModel>((ref, conversation) {
      final bloc = ChatBloc(
        repo: ref.watch(chatRepositoryProvider),
        client: ref.watch(supabaseClientProvider),
        conversationId: conversation.id,
      );
      ref.onDispose(bloc.close);
      return bloc;
    });
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
