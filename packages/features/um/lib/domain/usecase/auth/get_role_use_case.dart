import 'package:common/core/usecase/usecase.dart';
import 'package:um/domain/repositories/login_repository.dart';

class GetRoleUseCase extends BaseUseCase<String> {
  final LoginRepository loginRepo;

  GetRoleUseCase({required this.loginRepo});

  @override
  Future<String> call() => loginRepo.getRole();
}
