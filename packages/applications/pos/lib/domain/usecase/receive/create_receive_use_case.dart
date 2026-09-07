// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class CreateReceiveUseCase extends BaseUseCaseParam<ReceiveParam, Receive> {
  final ReceiveRepository receiveRepo;

  CreateReceiveUseCase({required this.receiveRepo});

  @override
  Future<Receive> call(ReceiveParam param) => receiveRepo.createReceive(param);
}
