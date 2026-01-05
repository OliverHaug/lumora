import 'package:xyz/core/errors/result.dart';
import '../../data/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repo;
  SignUpUseCase(this._repo);

  Future<Result<void>> call({required String email, required String password}) {
    return _repo.signUp(email: email, password: password);
  }
}
