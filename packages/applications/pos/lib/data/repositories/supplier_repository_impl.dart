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
    final mapper = SupplierMapper();
    final response = await posService.updateSupplierInfo(mapper.toSupplierRequest(param));
    final result = mapper.toSupplierDomain(jsonOrThrow(response));
    _suppliers.invalidate();
    return result;
  }

  @override
  Future<Supplier> getSupplierInfo() async {
    final mapper = SupplierMapper();
    final response = await posService.getSupplierInfo();
    return mapper.toSupplierDomain(jsonOrThrow(response));
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    final mapper = SupplierMapper();
    final response = await posService.getSuppliers();
    final suppliers = mapper.toSuppliersDomain(jsonOrThrow(response));
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
    final mapper = SupplierMapper();
    final response = await posService.getSupplierById(supplierId);
    return mapper.toSupplierDomain(jsonOrThrow(response));
  }

  @override
  Future<Supplier> removeSupplierById(String supplierId) async {
    final mapper = SupplierMapper();
    final response = await posService.removeSupplierById(supplierId);
    final result = mapper.toSupplierDomain(jsonOrThrow(response));
    _suppliers.invalidate();
    return result;
  }

  @override
  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param) async {
    final mapper = SupplierMapper();
    final response = await posService.updateSupplierById(supplierId, mapper.toSupplierRequest(param));
    final result = mapper.toSupplierDomain(jsonOrThrow(response));
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
    final mapper = SupplierMapper();
    final response = await posService.createSupplier(mapper.toSupplierRequest(param));
    final result = mapper.toSupplierDomain(jsonOrThrow(response));
    _suppliers.invalidate();
    return result;
  }
}
