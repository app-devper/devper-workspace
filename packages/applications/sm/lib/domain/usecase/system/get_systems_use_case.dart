// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/domain/repositories/system_repository.dart';

class GetSystemsUseCase extends BaseUseCase<List<System>> {
  final SystemRepository systemRepo;

  GetSystemsUseCase({required this.systemRepo});

  @override
  Future<List<System>> call() => systemRepo.getSystems();
}
