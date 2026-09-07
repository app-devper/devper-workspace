// Package imports:
import 'package:common/core/error/exception.dart';
import 'package:common/core/network/error_mapper.dart';
import 'package:common/core/network/exception.dart';

// Project imports:
import 'package:um/data/datasource/network/um_service.dart';
import 'package:um/data/repositories/user_mapper.dart';
import 'package:um/domain/entities/user/param.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UmService _service;

  UserRepositoryImpl({
    required UmService service,
  }) : _service = service;

  @override
  Future<User> getUserInfo() async {
    var mapper = UserMapper();
    final response = await _service.getUserInfo();
    return mapper.toUserDomain(jsonOrThrow(response));
  }

  @override
  Future<List<User>> getUsers() async {
    var mapper = UserMapper();
    final response = await _service.getUsers();
    return mapper.toUsersDomain(jsonOrThrow(response));
  }

  @override
  Future<User> getUserById(String userId) async {
    if (userId.isEmpty) {
      throw const ValidationException(message: "Invalid parameter");
    }
    var mapper = UserMapper();
    final response = await _service.getUserById(userId);
    return mapper.toUserDomain(jsonOrThrow(response));
  }

  @override
  Future<bool> changePassword(ChangePasswordParam param) async {
    if (param.oldPassword.isEmpty || param.newPassword.isEmpty) {
      throw const ValidationException(message: "Invalid parameter");
    }
    var mapper = UserMapper();
    final response = await _service.changePassword(mapper.toChangePasswordRequest(param));
    if (response.isSuccessful) {
      return true;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<bool> setPasswordById(SetPasswordParam param) async {
    if (param.password.isEmpty) {
      throw const ValidationException(message: "Invalid parameter");
    }
    var mapper = UserMapper();
    final response = await _service.setPasswordById(
        param.userId, mapper.toSetPasswordRequest(param.password));
    if (response.isSuccessful) {
      return true;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<User> removeUserById(String userId) async {
    if (userId.isEmpty) {
      throw const ValidationException(message: "Invalid parameter");
    }
    var mapper = UserMapper();
    final response = await _service.removeUserById(userId);
    return mapper.toUserDomain(jsonOrThrow(response));
  }

  @override
  Future<User> updateRoleById(UpdateRoleParam param) async {
    var mapper = UserMapper();
    final response = await _service.updateRoleById(param.userId, mapper.toUpdateRoleRequest(param.role));
    return mapper.toUserDomain(jsonOrThrow(response));
  }

  @override
  Future<User> updateStatusById(UpdateStatusParam param) async {
    var mapper = UserMapper();
    final response = await _service.updateStatusById(param.userId, mapper.toUpdateStatusRequest(param.status));
    return mapper.toUserDomain(jsonOrThrow(response));
  }

  @override
  Future<User> updateUserById(UpdateUserParam param) async {
    if (param.userParam.firstName.isEmpty || param.userParam.lastName.isEmpty) {
      throw const ValidationException(message: "Invalid parameter");
    }
    var mapper = UserMapper();
    final response = await _service.updateUserById(param.userId, mapper.toUpdateUserRequest(param.userParam));
    return mapper.toUserDomain(jsonOrThrow(response));
  }

  @override
  Future<User> updateUserInfo(UserParam param) async {
    if (param.firstName.isEmpty || param.lastName.isEmpty) {
      throw const ValidationException(message: "Invalid parameter");
    }
    var mapper = UserMapper();
    final response = await _service.updateUserInfo(mapper.toUpdateUserRequest(param));
    return mapper.toUserDomain(jsonOrThrow(response));
  }

  @override
  Future<User> createUser(CreateParam param) async {
    if (param.password.isEmpty || param.username.isEmpty) {
      throw const ValidationException(message: "Invalid parameter");
    }
    var mapper = UserMapper();
    final response = await _service.createUser(mapper.toCreateUserRequest(param));
    return mapper.toUserDomain(jsonOrThrow(response));
  }
}
