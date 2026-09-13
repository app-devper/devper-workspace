// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

/// What this screen renders: the record being edited, and whether the save
/// is in flight.
///
/// The outcome used to live here too, behind a sealed task the view cleared
/// once it had acted on it. It is not drawn — it closes the screen and hands
/// the result back — so it goes out on the view model's event channel.
@immutable
class SupplierInfoState {
  final bool saving;
  final Supplier? supplier;

  const SupplierInfoState({
    this.saving = false,
    this.supplier,
  });

  SupplierInfoState copyWith({
    bool? saving,
    Supplier? supplier,
  }) {
    return SupplierInfoState(
      saving: saving ?? this.saving,
      supplier: supplier ?? this.supplier,
    );
  }
}
