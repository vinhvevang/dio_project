import 'package:dio_complete/features/auth/domain/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _repository;

  AuthUseCase(this._repository);

  Future<String> login({required String username, required String password}) {
    return _repository.login(username: username, password: password);
  }
}