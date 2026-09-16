// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/receive_mapper.dart';
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

class ReceiveRepositoryImpl implements ReceiveRepository {
  final PosService posService;

  ReceiveRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Receive> createReceive(ReceiveParam param) async {
    final response = await posService.createReceive(param.toReceiveRequest());
    return (jsonOrThrow(response) as Map<String, dynamic>).toReceiveDomain();
  }

  @override
  Future<List<ReceiveItem>> getReceiveItemsById(String receiveId) async {
    return (await getReceiveById(receiveId)).items;
  }

  @override
  Future<Receive> getReceiveById(String receiveId) async {
    final response = await posService.getReceiveById(receiveId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toReceiveDomain();
  }

  @override
  Future<List<Receive>> getReceives(GetReceivesRangeParam param) async {
    final response =
        await posService.getReceives(param.startDate, param.endDate);
    return (jsonOrThrow(response) as List).toReceivesDomain();
  }

  @override
  Future<Receive> removeReceiveById(String receiveId) async {
    final response = await posService.removeReceiveById(receiveId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toReceiveDomain();
  }

  @override
  Future<Receive> importReceiveById(String receiveId) async {
    final response = await posService.importReceiveById(receiveId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toReceiveDomain();
  }

  @override
  Future<Receive> updateReceiveById(
      String receiveId, UpdateReceiveParam param) async {
    final response = await posService.updateReceiveById(
        receiveId, param.toUpdateReceiveRequest());
    return (jsonOrThrow(response) as Map<String, dynamic>).toReceiveDomain();
  }
}
