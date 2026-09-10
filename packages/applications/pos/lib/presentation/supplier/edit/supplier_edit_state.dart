// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

/// The mutually exclusive states of this screen's two commands.
///
/// Saving and deleting share the screen but not a slot: an update result and a
/// delete result can never both be present, which is what the four independent
/// nullable fields used to allow.
sealed class SupplierEditState {
  const SupplierEditState._();
  const factory SupplierEditState() = SupplierEditIdle;

  // Derived UI projections; no independently writable flags.
  bool get loading =>
      this is SupplierEditSaving || this is SupplierEditDeleting;
  String? get error => switch (this) {
        SupplierEditFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Supplier? get updated => switch (this) {
        SupplierEditUpdated(:final supplier) => supplier,
        _ => null,
      };
  Supplier? get removed => switch (this) {
        SupplierEditRemoved(:final supplier) => supplier,
        _ => null,
      };
}

final class SupplierEditIdle extends SupplierEditState {
  const SupplierEditIdle() : super._();
}

final class SupplierEditSaving extends SupplierEditState {
  const SupplierEditSaving() : super._();
}

final class SupplierEditDeleting extends SupplierEditState {
  const SupplierEditDeleting() : super._();
}

final class SupplierEditUpdated extends SupplierEditState {
  final Supplier supplier;
  const SupplierEditUpdated(this.supplier) : super._();
}

final class SupplierEditRemoved extends SupplierEditState {
  final Supplier supplier;
  const SupplierEditRemoved(this.supplier) : super._();
}

final class SupplierEditFailed extends SupplierEditState {
  final Failure failure;
  const SupplierEditFailed(this.failure) : super._();
}
