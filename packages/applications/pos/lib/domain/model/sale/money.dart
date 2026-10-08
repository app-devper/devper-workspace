/// Money on a Sale, as pos-api records it.
///
/// pos-api owns these rules (app/domain/sale/money.go) and the till only
/// previews them, so every figure here must come out the same as the server's.
/// test/fixtures/sale_money_cases.json is a copy of pos-api's case table:
/// change one side, change both.
library;

import 'dart:math' as math;

/// Rounds to the satang: half away from zero, on v×100 as a double — the same
/// float Go rounds, the same way. 4.445 rounds to 4.44 on both.
double roundMoney(double v) => (v * 100).round() / 100;

/// What one Line charges.
class Charge {
  /// Unit price × quantity, rounded, before discount.
  final double amount;

  /// Per unit, between 0 and the unit price.
  final double discount;

  /// What the customer pays for the Line.
  final double paid;

  const Charge._(this.amount, this.discount, this.paid);

  factory Charge.of(double unitPrice, int quantity, double discount) {
    final amount = roundMoney(unitPrice * quantity);
    final clamped = math.min(math.max(discount, 0.0), unitPrice);
    return Charge._(amount, clamped, roundMoney(amount - clamped * quantity));
  }
}

/// A Sale's total: each Line's paid amount is already rounded, and the sum is
/// rounded once.
double saleTotal(Iterable<double> paid) =>
    roundMoney(paid.fold(0.0, (sum, p) => sum + p));

/// Whether the money offered settles a total, and the change.
class Tender {
  final bool covers;
  final double change;

  const Tender._(this.covers, this.change);

  /// Change comes from the tender rounded to the satang, so 8.895 offered
  /// against 8.90 settles it with no change.
  factory Tender.of(double tendered, double total) {
    final offered = roundMoney(tendered);
    if (offered < total) return const Tender._(false, 0);
    return Tender._(true, roundMoney(offered - total));
  }
}
