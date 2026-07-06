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
    final mapper = ReceiveMapper();
    final response = await posService.createReceive(mapper.toReceiveRequest(param));
    return mapper.toReceiveDomain(jsonOrThrow(response));
  }

  @override
  Future<List<ReceiveItem>> getReceiveItemsById(String receiveId) async {
    final mapper = ReceiveMapper();
    final response = await posService.getReceiveProductLotsById(receiveId);
    return mapper.toReceiveItemsDomain(jsonOrThrow(response));
  }

  @override
  Future<Receive> getReceiveById(String receiveId) async {
    final mapper = ReceiveMapper();
    final response = await posService.getReceiveById(receiveId);
    return mapper.toReceiveDomain(jsonOrThrow(response));
  }

  @override
  Future<List<Receive>> getReceives(GetReceivesRangeParam param) async {
    final mapper = ReceiveMapper();
    final response = await posService.getReceives(param.startDate, param.endDate);
    return mapper.toReceivesDomain(jsonOrThrow(response));
  }

  @override
  Future<Receive> removeReceiveById(String receiveId) async {
    final mapper = ReceiveMapper();
    final response = await posService.removeReceiveById(receiveId);
    return mapper.toReceiveDomain(jsonOrThrow(response));
  }

  @override
  Future<ReceiveItem> removeReceiveItemByLotId(String lotId) async {
    final mapper = ReceiveMapper();
    final response = await posService.removeReceiveProductLotsByLotId(lotId);
    return mapper.toReceiveItemDomain(jsonOrThrow(response));
  }

  @override
  Future<Receive> updateReceiveById(String receiveId, UpdateReceiveParam param) async {
    final mapper = ReceiveMapper();
    final response = await posService.updateReceiveById(receiveId, mapper.toUpdateReceiveRequest(param));
    return mapper.toReceiveDomain(jsonOrThrow(response));
  }
}
