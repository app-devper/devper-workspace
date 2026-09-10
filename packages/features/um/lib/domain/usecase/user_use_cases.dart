import 'package:um/domain/repositories/user_repository.dart';
import 'package:um/domain/entities/user/param.dart';
import 'package:um/domain/entities/user/user.dart';

class GetUserUseCase {
  final UserRepository repository;
  const GetUserUseCase(this.repository);
  Future<User> call(String param) => repository.getUserById(param);
}

class GetUserInfoUseCase {
  final UserRepository repository;
  const GetUserInfoUseCase(this.repository);
  Future<User> call() => repository.getUserInfo();
}

class GetUsersUseCase {
  final UserRepository repository;
  const GetUsersUseCase(this.repository);
  Future<List<User>> call() => repository.getUsers();
}

class CreateUserUseCase {
  final UserRepository repository;
  const CreateUserUseCase(this.repository);
  Future<User> call(CreateParam param) => repository.createUser(param);
}

class UpdateUserUseCase {
  final UserRepository repository;
  const UpdateUserUseCase(this.repository);
  Future<User> call(UpdateUserParam param) => repository.updateUserById(param);
}

class UpdateUserInfoUseCase {
  final UserRepository repository;
  const UpdateUserInfoUseCase(this.repository);
  Future<User> call(UserParam param) => repository.updateUserInfo(param);
}

class RemoveUserUseCase {
  final UserRepository repository;
  const RemoveUserUseCase(this.repository);
  Future<User> call(String param) => repository.removeUserById(param);
}

class ChangePasswordUseCase {
  final UserRepository repository;
  const ChangePasswordUseCase(this.repository);
  Future<bool> call(ChangePasswordParam param) =>
      repository.changePassword(param);
}

class SetPasswordUseCase {
  final UserRepository repository;
  const SetPasswordUseCase(this.repository);
  Future<bool> call(SetPasswordParam param) =>
      repository.setPasswordById(param);
}
