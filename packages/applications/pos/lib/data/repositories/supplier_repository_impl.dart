// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/network/error_mapper.dart';
import 'package:common/core/network/exception.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/supplier_mapper.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final PosService posService;
  List<Supplier> _suppliers = [];

  SupplierRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Supplier> updateSupplierInfo(SupplierParam param) async {
    final mapper = SupplierMapper();
    final response = await posService.updateSupplierInfo(mapper.toSupplierRequest(param));
    return mapper.toSupplierDomain(jsonOrThrow(response));
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
    if (response.isSuccessful) {
      final suppliers = mapper.toSuppliersDomain(jsonDecode(response.body));
      _suppliers = suppliers;
      return suppliers;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<List<Supplier>> getLocalSuppliers() async {
    if (_suppliers.isEmpty) {
      return getSuppliers();
    } else {
      return Future.value(_suppliers);
    }
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
    return mapper.toSupplierDomain(jsonOrThrow(response));
  }

  @override
  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param) async {
    final mapper = SupplierMapper();
    final response = await posService.updateSupplierById(supplierId, mapper.toSupplierRequest(param));
    return mapper.toSupplierDomain(jsonOrThrow(response));
  }

  @override
  Future<Supplier?> getLocalSupplierById(String supplierId) async {
    final supplier = _suppliers.where((element) => element.id == supplierId).firstOrNull;
    if (supplier != null) {
      return Future.value(supplier);
    }
    return null;
  }

  @override
  Future<Supplier> createSupplier(SupplierParam param) async {
    final mapper = SupplierMapper();
    final response = await posService.createSupplier(mapper.toSupplierRequest(param));
    return mapper.toSupplierDomain(jsonOrThrow(response));
  }
}
