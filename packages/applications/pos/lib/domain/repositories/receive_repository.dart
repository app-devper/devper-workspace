// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';

abstract class ReceiveRepository {
  Future<Receive> createReceive(ReceiveParam param);

  Future<List<Receive>> getReceives(GetReceivesRangeParam param);

  Future<Receive> getReceiveById(String receiveId);

  Future<Receive> updateReceiveById(String receiveId, UpdateReceiveParam param);

  Future<Receive> removeReceiveById(String receiveId);

  Future<List<ReceiveItem>> getReceiveItemsById(String receiveId);

  Future<Receive> importReceiveById(String receiveId);
}
