// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class SupplierRepository {
  Future<Supplier> createSupplier(SupplierParam param);

  Future<Supplier> updateSupplierInfo(SupplierParam param);

  Future<Supplier> getSupplierInfo();

  Future<List<Supplier>> getSuppliers();

  Future<List<Supplier>> getLocalSuppliers();

  Future<Supplier> getSupplierById(String supplierId);

  Future<Supplier?> getLocalSupplierById(String supplierId);

  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param);

  Future<Supplier> removeSupplierById(String supplierId);
}
