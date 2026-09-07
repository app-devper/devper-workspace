import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';
import 'package:pos/domain/usecase/receive/get_receives_use_case.dart';
import 'package:pos/presentation/receive/main/receives_view_model.dart';

class FakeReceiveRepository implements ReceiveRepository {
  final List<Receive> receives;
  final Object? throws;

  FakeReceiveRepository({this.receives = const [], this.throws});

  @override
  Future<List<Receive>> getReceives(GetReceivesRangeParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return receives;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Receive buildReceive(String id, String code) {
  return Receive(id: id, supplierId: 's1', code: code, reference: '', totalCost: 0, createdDate: '');
}

ReceivesViewModel buildViewModel(ReceiveRepository repo) {
  return ReceivesViewModel(
    getReceivesUseCase: GetReceivesUseCase(receiveRepo: repo),
  );
}

void main() {
  test('getReceives populates items and clears loading', () async {
    final vm = buildViewModel(
      FakeReceiveRepository(receives: [buildReceive('1', 'RC-1'), buildReceive('2', 'RC-2')]),
    );

    await vm.getReceives();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.items, hasLength(2));
    expect(vm.state.value.error, isNull);
  });

  test('searchReceive triggers the initial load when nothing is cached', () async {
    final vm = buildViewModel(FakeReceiveRepository(receives: [buildReceive('1', 'RC-1')]));

    vm.searchReceive('');
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.items, hasLength(1));
  });

  test('searchReceive filters the cached list by code', () async {
    final vm = buildViewModel(
      FakeReceiveRepository(receives: [buildReceive('1', 'ABC'), buildReceive('2', 'XYZ')]),
    );

    await vm.getReceives();
    vm.searchReceive('xy');

    expect(vm.state.value.items, hasLength(1));
    expect(vm.state.value.items.first.code, 'XYZ');
  });

  test('getReceives maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeReceiveRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getReceives();

    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.items, isEmpty);

    vm.consumeError();
    expect(vm.state.value.error, isNull);
  });
}
