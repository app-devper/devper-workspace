// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/supplier_mapper.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final PosService posService;
  final _suppliers = CachedList<Supplier>();

  SupplierRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Supplier> updateSupplierInfo(SupplierParam param) async {
    final response =
        await posService.updateSupplierInfo(param.toSupplierRequest());
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toSupplierDomain();
    _suppliers.invalidate();
    return result;
  }

  @override
  Future<Supplier> getSupplierInfo() async {
    final response = await posService.getSupplierInfo();
    return (jsonOrThrow(response) as Map<String, dynamic>).toSupplierDomain();
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    final response = await posService.getSuppliers();
    final suppliers = (jsonOrThrow(response) as List).toSuppliersDomain();
    _suppliers.fill(suppliers);
    return suppliers;
  }

  @override
  Future<List<Supplier>> getLocalSuppliers() async {
    if (_suppliers.needsRefresh) {
      return getSuppliers();
    }
    return Future.value(_suppliers.items);
  }

  @override
  Future<Supplier> getSupplierById(String supplierId) async {
    final response = await posService.getSupplierById(supplierId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toSupplierDomain();
  }

  @override
  Future<Supplier> removeSupplierById(String supplierId) async {
    final response = await posService.removeSupplierById(supplierId);
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toSupplierDomain();
    _suppliers.invalidate();
    return result;
  }

  @override
  Future<Supplier> updateSupplierById(
      String supplierId, SupplierParam param) async {
    final response = await posService.updateSupplierById(
        supplierId, param.toSupplierRequest());
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toSupplierDomain();
    _suppliers.invalidate();
    return result;
  }

  @override
  Future<Supplier?> getLocalSupplierById(String supplierId) async {
    final suppliers = await getLocalSuppliers();
    return suppliers.where((element) => element.id == supplierId).firstOrNull;
  }

  @override
  Future<Supplier> createSupplier(SupplierParam param) async {
    final response = await posService.createSupplier(param.toSupplierRequest());
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toSupplierDomain();
    _suppliers.invalidate();
    return result;
  }
}
