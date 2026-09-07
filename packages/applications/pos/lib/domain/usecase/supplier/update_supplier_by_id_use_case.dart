// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class UpdateSupplierByIdUseCase extends BaseUseCaseParam<SupplierUpdateParam, Supplier> {
  final SupplierRepository supplierRepo;

  UpdateSupplierByIdUseCase({required this.supplierRepo});

  @override
  Future<Supplier> call(SupplierUpdateParam param) =>
      supplierRepo.updateSupplierById(param.supplierId, param.param);
}
