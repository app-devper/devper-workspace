// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:sm/domain/model/system/param.dart';
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/domain/repositories/system_repository.dart';

class UpdateSystemByIdUseCase extends BaseUseCaseParam<UpdateSystemParam, System> {
  final SystemRepository systemRepo;

  UpdateSystemByIdUseCase({required this.systemRepo});

  @override
  Future<System> call(UpdateSystemParam param) => systemRepo.updateSystemById(param);
}
