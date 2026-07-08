// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/usecase/receive/get_receives_use_case.dart';
import 'package:pos/presentation/receive/main/receive_state.dart';

class ReceivesViewModel {
  final GetReceivesUseCase getReceivesUseCase;

  ReceivesViewModel({
    required this.getReceivesUseCase,
  });

  final _state = ValueNotifier<ReceivesState>(const ReceivesState());

  ValueListenable<ReceivesState> get state => _state;

  List<Receive> _all = const [];
  String _query = '';

  void searchReceive(String query) {
    _query = query;
    if (_all.isEmpty && !_state.value.loading) {
      getReceives();
    } else {
      _state.value = _state.value.copyWith(items: _filter(query));
    }
  }

  Future<void> getReceives() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 365));
      final param = GetReceivesRangeParam(
        startDate: startDate.toUtc().toIso8601String(),
        endDate: now.toUtc().toIso8601String(),
      );
      _all = await getReceivesUseCase(param);
      _state.value = _state.value.copyWith(loading: false, items: _filter(_query));
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  List<Receive> _filter(String query) {
    if (query.isEmpty) {
      return _all;
    }
    final lower = query.toLowerCase();
    return _all.where((item) => item.code.toLowerCase().contains(lower)).toList();
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
