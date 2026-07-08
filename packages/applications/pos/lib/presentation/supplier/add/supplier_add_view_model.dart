// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/usecase/supplier/create_supplier_use_case.dart';
import 'package:pos/presentation/supplier/add/supplier_add_state.dart';

class SupplierAddViewModel {
  final CreateSupplierUseCase createSupplierUseCase;

  SupplierAddViewModel({
    required this.createSupplierUseCase,
  });

  final _state = ValueNotifier<SupplierAddState>(const SupplierAddState());

  ValueListenable<SupplierAddState> get state => _state;

  Future<void> createSupplier(SupplierParam param) async {
    _state.value = _state.value.copyWith(saving: true, clearError: true, clearCreated: true);
    try {
      final created = await createSupplierUseCase(param);
      _state.value = _state.value.copyWith(saving: false, created: created);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(saving: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeCreated() {
    if (_state.value.created != null) {
      _state.value = _state.value.copyWith(clearCreated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
