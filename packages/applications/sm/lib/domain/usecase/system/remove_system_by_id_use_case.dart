// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/domain/repositories/system_repository.dart';

class RemoveSystemByIdUseCase extends BaseUseCaseParam<String, System> {
  final SystemRepository systemRepo;

  RemoveSystemByIdUseCase({required this.systemRepo});

  @override
  Future<System> call(String systemId) => systemRepo.removeSystemById(systemId);
}
