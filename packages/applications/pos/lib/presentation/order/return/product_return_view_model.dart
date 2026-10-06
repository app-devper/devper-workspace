// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/presentation/order/return/product_return_state.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';

class ProductReturnViewModel {
  final ProductReturnRepository productReturnRepo;

  ProductReturnViewModel({
    required this.productReturnRepo,
  });

  final _state = ValueNotifier<ProductReturnState>(const ProductReturnState());

  /// Delivered once: the sheet closes on it, nothing draws it.
  final _created = OneShot<ProductReturn>();
  final _errors = OneShot<String>();

  ValueListenable<ProductReturnState> get state => _state;

  Stream<ProductReturn> get created => _created.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> createProductReturn(CreateProductReturnParam param) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final created = await productReturnRepo.createProductReturn(param);
      _created.emit(created);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _created.dispose();
    _errors.dispose();
  }
}
