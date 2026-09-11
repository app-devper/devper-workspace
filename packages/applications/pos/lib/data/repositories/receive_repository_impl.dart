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
  static const _mapper = ReceiveMapper();

  final PosService posService;

  ReceiveRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Receive> createReceive(ReceiveParam param) async {
    final response =
        await posService.createReceive(_mapper.toReceiveRequest(param));
    return _mapper.toReceiveDomain(jsonOrThrow(response));
  }

  @override
  Future<List<ReceiveItem>> getReceiveItemsById(String receiveId) async {
    return (await getReceiveById(receiveId)).items;
  }

  @override
  Future<Receive> getReceiveById(String receiveId) async {
    final response = await posService.getReceiveById(receiveId);
    return _mapper.toReceiveDomain(jsonOrThrow(response));
  }

  @override
  Future<List<Receive>> getReceives(GetReceivesRangeParam param) async {
    final response =
        await posService.getReceives(param.startDate, param.endDate);
    return _mapper.toReceivesDomain(jsonOrThrow(response));
  }

  @override
  Future<Receive> removeReceiveById(String receiveId) async {
    final response = await posService.removeReceiveById(receiveId);
    return _mapper.toReceiveDomain(jsonOrThrow(response));
  }

  @override
  Future<Receive> importReceiveById(String receiveId) async {
    final response = await posService.importReceiveById(receiveId);
    return _mapper.toReceiveDomain(jsonOrThrow(response));
  }

  @override
  Future<Receive> updateReceiveById(
      String receiveId, UpdateReceiveParam param) async {
    final response = await posService.updateReceiveById(
        receiveId, _mapper.toUpdateReceiveRequest(param));
    return _mapper.toReceiveDomain(jsonOrThrow(response));
  }
}
