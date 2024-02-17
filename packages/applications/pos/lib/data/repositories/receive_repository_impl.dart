// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/network/exception.dart';

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
    if (response.isSuccessful) {
      return mapper.toReceiveDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<ReceiveItem>> getReceiveItemsById(String receiveId) async {
    final mapper = ReceiveMapper();
    final response = await posService.getReceiveProductLotsById(receiveId);
    if (response.isSuccessful) {
      return mapper.toReceiveItemsDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Receive> getReceiveById(String receiveId) async {
    final mapper = ReceiveMapper();
    final response = await posService.getReceiveById(receiveId);
    if (response.isSuccessful) {
      return mapper.toReceiveDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<Receive>> getReceives(GetReceivesRangeParam param) async {
    final mapper = ReceiveMapper();
    final response = await posService.getReceives(param.startDate, param.endDate);
    if (response.isSuccessful) {
      return mapper.toReceivesDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Receive> removeReceiveById(String receiveId) async {
    final mapper = ReceiveMapper();
    final response = await posService.removeReceiveById(receiveId);
    if (response.isSuccessful) {
      return mapper.toReceiveDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ReceiveItem> removeReceiveItemByLotId(String lotId) async {
    final mapper = ReceiveMapper();
    final response = await posService.removeReceiveProductLotsByLotId(lotId);
    if (response.isSuccessful) {
      return mapper.toReceiveItemDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Receive> updateReceiveById(String receiveId, UpdateReceiveParam param) async {
    final mapper = ReceiveMapper();
    final response = await posService.updateReceiveById(receiveId, mapper.toUpdateReceiveRequest(param));
    if (response.isSuccessful) {
      return mapper.toReceiveDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }
}
