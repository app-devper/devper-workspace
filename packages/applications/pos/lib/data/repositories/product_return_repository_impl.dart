// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/product_return_mapper.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';

class ProductReturnRepositoryImpl implements ProductReturnRepository {
  final PosService posService;

  ProductReturnRepositoryImpl({
    required this.posService,
  });

  @override
  Future<ProductReturn> createProductReturn(CreateProductReturnParam param) async {
    final mapper = ProductReturnMapper();
    final response = await posService.createProductReturn(mapper.toProductReturnRequest(param));
    return mapper.toProductReturnDomain(jsonOrThrow(response));
  }

  @override
  Future<List<ProductReturn>> getProductReturnsByOrderId(String orderId) async {
    final mapper = ProductReturnMapper();
    final response = await posService.getProductReturnsByOrderId(orderId);
    return mapper.toProductReturnsDomain(jsonOrThrow(response));
  }
}
