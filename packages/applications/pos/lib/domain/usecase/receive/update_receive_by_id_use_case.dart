// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class UpdateReceiveByIdUseCase extends BaseUseCaseParam<ReceiveUpdateParam, Receive> {
  final ReceiveRepository receiveRepo;

  UpdateReceiveByIdUseCase({required this.receiveRepo});

  @override
  Future<Receive> call(ReceiveUpdateParam param) =>
      receiveRepo.updateReceiveById(param.receiveId, param.param);
}
