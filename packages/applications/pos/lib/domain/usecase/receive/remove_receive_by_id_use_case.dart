// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class RemoveReceiveByIdUseCase extends BaseUseCaseParam<String, Receive> {
  final ReceiveRepository receiveRepo;

  RemoveReceiveByIdUseCase({required this.receiveRepo});

  @override
  Future<Receive> call(String receiveId) => receiveRepo.removeReceiveById(receiveId);
}
