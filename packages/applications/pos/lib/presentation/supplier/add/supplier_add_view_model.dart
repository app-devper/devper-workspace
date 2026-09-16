// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/usecase/supplier/create_supplier_use_case.dart';
import 'package:pos/presentation/supplier/add/supplier_add_state.dart';

class SupplierAddViewModel {
  final CreateSupplierUseCase createSupplierUseCase;

  SupplierAddViewModel({
    required this.createSupplierUseCase,
  });

  final _state = ValueNotifier<SupplierAddState>(const SupplierAddState());

  /// The two things the screen reacts to once each. Neither is drawn, so
  /// neither belongs in state, and there is nothing for the view to clear.
  final _created = OneShot<Supplier>();
  final _errors = OneShot<String>();

  ValueListenable<SupplierAddState> get state => _state;

  Stream<Supplier> get created => _created.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> createSupplier(SupplierParam param) async {
    if (_state.value.saving) return;
    _state.value = _state.value.copyWith(saving: true);
    try {
      _created.emit(await createSupplierUseCase(param));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(saving: false);
    }
  }

  void dispose() {
    _state.dispose();
    _created.dispose();
    _errors.dispose();
  }
}
