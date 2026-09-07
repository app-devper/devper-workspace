// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class UpdateSupplierInfoUseCase extends BaseUseCaseParam<SupplierParam, Supplier> {
  final SupplierRepository supplierRepo;

  UpdateSupplierInfoUseCase({required this.supplierRepo});

  @override
  Future<Supplier> call(SupplierParam param) => supplierRepo.updateSupplierInfo(param);
}
