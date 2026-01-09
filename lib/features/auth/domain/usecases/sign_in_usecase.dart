import 'package:lumora/core/errors/result.dart';
import '../../data/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repo;
  SignInUseCase(this._repo);

  Future<Result<void>> call({required String email, required String password}) {
    return _repo.signIn(email: email, password: password);
  }
}
