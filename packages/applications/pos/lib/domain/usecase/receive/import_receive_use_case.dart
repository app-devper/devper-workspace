import 'package:common/core/usecase/usecase.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class ImportReceiveUseCase extends BaseUseCaseParam<String, Receive> {
  final ReceiveRepository receiveRepo;
  ImportReceiveUseCase({required this.receiveRepo});
  @override
  Future<Receive> call(String receiveId) =>
      receiveRepo.importReceiveById(receiveId);
}
