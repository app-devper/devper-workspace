// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/usecase/supplier/get_supplier_info_use_case.dart';
import 'package:pos/domain/usecase/supplier/update_supplier_info_use_case.dart';
import 'package:pos/presentation/supplier/info/supplier_info_state.dart';

class SupplierInfoViewModel {
  final GetSupplierInfoUseCase getSupplierInfoUseCase;
  final UpdateSupplierInfoUseCase updateSupplierInfoUseCase;

  SupplierInfoViewModel({
    required this.getSupplierInfoUseCase,
    required this.updateSupplierInfoUseCase,
  });

  final _state = ValueNotifier<SupplierInfoState>(const SupplierInfoState());

  ValueListenable<SupplierInfoState> get state => _state;

  Future<void> getSupplierInfo() async {
    _state.value = _state.value.copyWith(clearError: true);
    try {
      final supplier = await getSupplierInfoUseCase();
      _state.value = _state.value.copyWith(supplier: supplier);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> updateSupplierInfo(SupplierParam param) async {
    _state.value = _state.value
        .copyWith(saving: true, clearError: true, clearUpdated: true);
    try {
      final updated = await updateSupplierInfoUseCase(param);
      _state.value = _state.value.copyWith(saving: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(saving: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
