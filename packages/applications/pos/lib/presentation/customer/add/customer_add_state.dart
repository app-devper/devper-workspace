// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

@immutable
class CustomerAddState {
  final bool saving;
  final String? error;
  final Customer? created;

  const CustomerAddState({
    this.saving = false,
    this.error,
    this.created,
  });

  CustomerAddState copyWith({
    bool? saving,
    String? error,
    Customer? created,
    bool clearError = false,
    bool clearCreated = false,
  }) {
    return CustomerAddState(
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
      created: clearCreated ? null : (created ?? this.created),
    );
  }
}
