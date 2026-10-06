// Project imports:
import 'package:pos/domain/model/sale/sale.dart';

/// The counter's parked Sales, and which one the cashier has open.
///
/// A customer who has to go back for one more thing steps aside; the next in
/// the queue is rung up on another slot. That is all this module does — it
/// holds slots and knows which is open. Everything about a purchase belongs to
/// the [Sale] in the slot, which is why a Sale has no notion of an index to be
/// handed the wrong one.
class Till {
  Till({this.size = 8});

  final int size;

  final Map<int, Sale> _sales = {};

  int _openIndex = 0;

  int get openIndex => _openIndex;

  /// The sale being rung up. A slot comes into being when it is first used.
  Sale get open => _sales[_openIndex] ??= Sale();

  /// Whether a parked slot has anything in it, for the cashier to see which
  /// ones are in use.
  bool hasLines(int index) => !(_sales[index]?.isEmpty ?? true);

  void switchTo(int index) {
    if (index < 0 || index >= size) return;
    _openIndex = index;
  }
}
