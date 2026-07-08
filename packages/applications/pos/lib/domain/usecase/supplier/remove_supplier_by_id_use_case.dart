// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class RemoveSupplierByIdUseCase extends BaseUseCaseParam<String, Supplier> {
  final SupplierRepository supplierRepo;

  RemoveSupplierByIdUseCase({required this.supplierRepo});

  @override
  Future<Supplier> call(String supplierId) => supplierRepo.removeSupplierById(supplierId);
}
