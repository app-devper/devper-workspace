// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class GetLocalSuppliersUseCase extends BaseUseCase<List<Supplier>> {
  final SupplierRepository supplierRepo;

  GetLocalSuppliersUseCase({required this.supplierRepo});

  @override
  Future<List<Supplier>> call() => supplierRepo.getLocalSuppliers();
}
