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
    _state.value = _state.value.copyWith(task: const SupplierAddRunning());
    try {
      final created = await createSupplierUseCase(param);
      _state.value = _state.value.copyWith(task: SupplierAddCreated(created));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: SupplierAddFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is SupplierAddFailed) {
      _state.value = _state.value.copyWith(task: const SupplierAddTask());
    }
  }

  void consumeCreated() {
    if (_state.value.task is SupplierAddCreated) {
      _state.value = _state.value.copyWith(task: const SupplierAddTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
