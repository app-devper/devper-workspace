// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:sm/data/datasource/network/sm_service.dart';
import 'package:sm/data/repositories/system_mapper.dart';
import 'package:sm/domain/model/system/param.dart';
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/domain/repositories/system_repository.dart';

class SystemRepositoryImpl implements SystemRepository {
  final SmService service;

  SystemRepositoryImpl({
    required this.service,
  });

  @override
  Future<System> createSystem(CreateParam param) async {
    var mapper = SystemMapper();
    final response = await service.createSystem(mapper.toCreateSystemRequest(param));
    return mapper.toSystemDomain(jsonOrThrow(response));
  }

  @override
  Future<System> getSystemById(String systemId) async {
    var mapper = SystemMapper();
    final response = await service.getSystemById(systemId);
    return mapper.toSystemDomain(jsonOrThrow(response));
  }

  @override
  Future<List<System>> getSystems() async {
    var mapper = SystemMapper();
    final response = await service.getSystems();
    return mapper.toSystemsDomain(jsonOrThrow(response));
  }

  @override
  Future<System> removeSystemById(String systemId) async {
    var mapper = SystemMapper();
    final response = await service.removeSystemById(systemId);
    return mapper.toSystemDomain(jsonOrThrow(response));
  }

  @override
  Future<System> updateSystemById(UpdateSystemParam param) async {
    var mapper = SystemMapper();
    final response = await service.updateSystemById(param.systemId, mapper.toUpdateSystemRequest(param));
    return mapper.toSystemDomain(jsonOrThrow(response));
  }
}
