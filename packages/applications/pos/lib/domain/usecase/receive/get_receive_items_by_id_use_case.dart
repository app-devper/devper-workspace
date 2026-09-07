// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class GetReceiveItemsByIdUseCase extends BaseUseCaseParam<String, List<ReceiveItem>> {
  final ReceiveRepository receiveRepo;

  GetReceiveItemsByIdUseCase({required this.receiveRepo});

  @override
  Future<List<ReceiveItem>> call(String receiveId) => receiveRepo.getReceiveItemsById(receiveId);
}
