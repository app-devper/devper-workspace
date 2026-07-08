// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class GetReceivesUseCase extends BaseUseCaseParam<GetReceivesRangeParam, List<Receive>> {
  final ReceiveRepository receiveRepo;

  GetReceivesUseCase({required this.receiveRepo});

  @override
  Future<List<Receive>> call(GetReceivesRangeParam param) => receiveRepo.getReceives(param);
}
