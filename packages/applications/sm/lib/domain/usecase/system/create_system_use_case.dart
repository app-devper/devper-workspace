// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:sm/domain/model/system/param.dart';
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/domain/repositories/system_repository.dart';

class CreateSystemUseCase extends BaseUseCaseParam<CreateParam, System> {
  final SystemRepository systemRepo;

  CreateSystemUseCase({required this.systemRepo});

  @override
  Future<System> call(CreateParam param) => systemRepo.createSystem(param);
}
