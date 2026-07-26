import 'package:common/core/usecase/usecase.dart';
import 'package:um/domain/repositories/login_repository.dart';

class LogoutUseCase extends BaseUseCase<bool> {
  final LoginRepository loginRepo;

  LogoutUseCase({required this.loginRepo});

  @override
  Future<bool> call() => loginRepo.logoutUser();
}
