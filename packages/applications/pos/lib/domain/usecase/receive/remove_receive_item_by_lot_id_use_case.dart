// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class RemoveReceiveItemByLotIdUseCase extends BaseUseCaseParam<String, ReceiveItem> {
  final ReceiveRepository receiveRepo;

  RemoveReceiveItemByLotIdUseCase({required this.receiveRepo});

  @override
  Future<ReceiveItem> call(String lotId) => receiveRepo.removeReceiveItemByLotId(lotId);
}
