import 'package:xyz/core/errors/result.dart';
import '../../data/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repo;
  SignOutUseCase(this._repo);

  Future<Result<void>> call() => _repo.signOut();
}
