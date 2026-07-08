// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class GetSupplierInfoUseCase extends BaseUseCase<Supplier> {
  final SupplierRepository supplierRepo;

  GetSupplierInfoUseCase({required this.supplierRepo});

  @override
  Future<Supplier> call() => supplierRepo.getSupplierInfo();
}
