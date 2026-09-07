import 'package:pos/domain/repositories/product_repository.dart';
import 'dart:async';
import 'package:common/localizations/localizations_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/container.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';
import 'package:pos/domain/usecase/product_return/create_product_return_use_case.dart';
import 'package:pos/presentation/order/return/product_return_view_model.dart';
import 'package:pos/presentation/order/return/product_return_widget.dart';

class Products implements ProductRepository {
  @override
  void invalidateProductsCache() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ReturnRepo implements ProductReturnRepository {
  late Completer<ProductReturn> pending;
  int calls = 0;
  @override
  Future<ProductReturn> createProductReturn(CreateProductReturnParam param) {
    calls++;
    pending = Completer<ProductReturn>();
    return pending.future;
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ReturnRepo repo;
  late ProductReturnViewModel vm;
  setUp(() {
    repo = ReturnRepo();
    vm = ProductReturnViewModel(createProductReturnUseCase:
      CreateProductReturnUseCase(productReturnRepo: repo, productRepo: Products()));
    sl.registerFactory<ProductReturnViewModel>(() => vm);
  });
  tearDown(() async { await sl.reset(); });

  Future<void> openForm(WidgetTester tester, VoidCallback complete) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [CommonLocalizationsDelegate()],
      home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () => showDialog<void>(context: context, builder: (_) => Dialog(
          child: SizedBox(width: 400, height: 550, child: ProductReturnWidget(
            orderId: 'order', orderItemId: 'item', productName: 'Test product',
            price: 30, maxReturnable: 1, onComplete: complete,
          )),
        )), child: const Text('Open return'),
      ))),
    ));
    await tester.tap(find.text('Open return'));
    await tester.pumpAndSettle();
  }

  testWidgets('success closes loading and form but preserves parent route', (tester) async {
    var completed = 0;
    await openForm(tester, () => completed++);
    await tester.tap(find.text('ยืนยัน'));
    await tester.pump();
    // A second caller while the request is pending must not send another mutation.
    await vm.createProductReturn(CreateProductReturnParam(orderId: 'order', reason: '', items: []));
    expect(repo.calls, 1);
    repo.pending.complete(ProductReturn(id: 'return', returnNo: 'RT1', orderId: 'order',
      customerCode: '', reason: '', items: [], totalRefund: 30, createdDate: '2026-09-07'));
    await tester.pumpAndSettle();
    expect(completed, 1);
    expect(find.text('Open return'), findsOneWidget);
    expect(find.byType(ProductReturnWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed request keeps the form open after error is consumed', (tester) async {
    await openForm(tester, () => fail('must not complete'));
    await tester.tap(find.text('ยืนยัน'));
    await tester.pump();
    repo.pending.completeError(Exception('failed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductReturnWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final invalid in ['NaN', 'Infinity', '-1']) {
    testWidgets('rejects invalid refund $invalid', (tester) async {
      await openForm(tester, () {});
      await tester.enterText(find.byType(TextFormField).at(1), invalid);
      await tester.tap(find.text('ยืนยัน'));
      await tester.pump();
      expect(repo.calls, 0);
    });
  }
}
