import 'package:common/core/error/failure.dart';
import 'package:pos/domain/model/product_return/product_return.dart';

/// The mutually exclusive states of this screen's submit flow.
sealed class ProductReturnState {
  const ProductReturnState._();
  const factory ProductReturnState() = ProductReturnIdle;

  // Derived UI projections; no independently writable boolean flags.
  bool get loading => this is ProductReturnSubmitting;
  String? get error => switch (this) {
        ProductReturnFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  ProductReturn? get created => switch (this) {
        ProductReturnSucceeded(:final result) => result,
        _ => null,
      };
}

final class ProductReturnIdle extends ProductReturnState {
  const ProductReturnIdle() : super._();
}

final class ProductReturnSubmitting extends ProductReturnState {
  const ProductReturnSubmitting() : super._();
}

final class ProductReturnSucceeded extends ProductReturnState {
  final ProductReturn result;
  const ProductReturnSucceeded(this.result) : super._();
}

final class ProductReturnFailed extends ProductReturnState {
  final Failure failure;
  const ProductReturnFailed(this.failure) : super._();
}
