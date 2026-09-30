import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/sale/sale.dart';
import 'package:pos/domain/repositories/order_repository.dart';

sealed class SaleCheckoutResult {
  const SaleCheckoutResult();
}

final class SaleCheckoutRecorded extends SaleCheckoutResult {
  final OrderResult order;
  const SaleCheckoutRecorded(this.order);
}

final class SaleCheckoutRejected extends SaleCheckoutResult {
  final String message;
  const SaleCheckoutRejected(this.message);
}

final class SaleCheckoutPending extends SaleCheckoutResult {
  const SaleCheckoutPending();
}

/// Owns the Sale submitted, even if the cashier opens another Till slot or
/// the view goes away. A confirmed Order completes that exact Sale; a failed
/// request leaves it intact, with the same id for a safe retry.
class CheckoutSaleUseCase {
  CheckoutSaleUseCase({required this.orderRepo});

  final OrderRepository orderRepo;
  final Set<Sale> _submitting = {};

  bool isSubmitting(Sale sale) => _submitting.contains(sale);

  Future<SaleCheckoutResult> call(
    Sale sale, {
    required double tendered,
    required String type,
  }) async {
    if (isSubmitting(sale)) return const SaleCheckoutPending();
    if (sale.isEmpty) return const SaleCheckoutRejected('ไม่มีสินค้าในบิล');
    if (!tendered.isFinite || !sale.covers(tendered)) {
      return const SaleCheckoutRejected('คุณรับเงินน้อยกว่ายอดราคาสินค้า');
    }
    final submitted = sale.toOrder(tendered: tendered, type: type);
    _submitting.add(sale);
    try {
      final result = await orderRepo.createOrder(submitted);
      sale.clear();
      return SaleCheckoutRecorded(result);
    } finally {
      _submitting.remove(sale);
    }
  }
}
