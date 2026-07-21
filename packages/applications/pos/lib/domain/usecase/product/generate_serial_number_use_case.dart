// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:

import 'package:pos/domain/repositories/product_repository.dart';

class GenerateSerialNumberUseCase extends BaseUseCase<String> {
  final ProductRepository productRepo;

  GenerateSerialNumberUseCase({required this.productRepo});

  @override
  Future<String> call() => productRepo.generateSerialNumber();
}
