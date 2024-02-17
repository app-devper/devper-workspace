// Project imports:
import 'package:sm/domain/model/system/param.dart';
import 'package:sm/domain/model/system/system.dart';

abstract class SystemRepository {

  Future<List<System>> getSystems();

  Future<System> createSystem(CreateParam param);

  Future<System> getSystemById(String systemId);

  Future<System> updateSystemById(UpdateSystemParam param);

  Future<System> removeSystemById(String systemId);

}
