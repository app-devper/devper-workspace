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
    _state.value = _state.value.copyWith(task: const SupplierInfoTask());
    try {
      final supplier = await getSupplierInfoUseCase();
      _state.value = _state.value.copyWith(supplier: supplier);
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: SupplierInfoFailed(toFailure(e)));
    }
  }

  Future<void> updateSupplierInfo(SupplierParam param) async {
    _state.value = _state.value.copyWith(task: const SupplierInfoRunning());
    try {
      final updated = await updateSupplierInfoUseCase(param);
      _state.value = _state.value.copyWith(task: SupplierInfoUpdated(updated));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: SupplierInfoFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is SupplierInfoFailed) {
      _state.value = _state.value.copyWith(task: const SupplierInfoTask());
    }
  }

  void consumeUpdated() {
    if (_state.value.task is SupplierInfoUpdated) {
      _state.value = _state.value.copyWith(task: const SupplierInfoTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
