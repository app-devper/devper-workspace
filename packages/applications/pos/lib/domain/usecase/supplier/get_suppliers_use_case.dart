// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class GetSuppliersUseCase extends BaseUseCase<List<Supplier>> {
  final SupplierRepository supplierRepo;

  GetSuppliersUseCase({required this.supplierRepo});

  @override
  Future<List<Supplier>> call() => supplierRepo.getSuppliers();
}
