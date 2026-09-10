// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

/// The mutually exclusive states of this screen's two commands.
///
/// Saving and deleting share the screen but not a slot: an update result and a
/// delete result can never both be present, which is what the four independent
/// nullable fields used to allow.
sealed class CustomerEditState {
  const CustomerEditState._();
  const factory CustomerEditState() = CustomerEditIdle;

  // Derived UI projections; no independently writable flags.
  bool get loading =>
      this is CustomerEditSaving || this is CustomerEditDeleting;
  String? get error => switch (this) {
        CustomerEditFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Customer? get updated => switch (this) {
        CustomerEditUpdated(:final customer) => customer,
        _ => null,
      };
  Customer? get removed => switch (this) {
        CustomerEditRemoved(:final customer) => customer,
        _ => null,
      };
}

final class CustomerEditIdle extends CustomerEditState {
  const CustomerEditIdle() : super._();
}

final class CustomerEditSaving extends CustomerEditState {
  const CustomerEditSaving() : super._();
}

final class CustomerEditDeleting extends CustomerEditState {
  const CustomerEditDeleting() : super._();
}

final class CustomerEditUpdated extends CustomerEditState {
  final Customer customer;
  const CustomerEditUpdated(this.customer) : super._();
}

final class CustomerEditRemoved extends CustomerEditState {
  final Customer customer;
  const CustomerEditRemoved(this.customer) : super._();
}

final class CustomerEditFailed extends CustomerEditState {
  final Failure failure;
  const CustomerEditFailed(this.failure) : super._();
}
