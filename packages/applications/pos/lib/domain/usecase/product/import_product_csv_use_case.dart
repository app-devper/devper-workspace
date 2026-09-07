// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ImportProductCSVUseCase extends BaseUseCaseParam<ImportProductCSVParam, CSVImportResult> {
  final ProductRepository productRepo;

  ImportProductCSVUseCase({required this.productRepo});

  @override
  Future<CSVImportResult> call(ImportProductCSVParam param) => productRepo.importProductCSV(bytes: param.bytes, filename: param.filename);
}
