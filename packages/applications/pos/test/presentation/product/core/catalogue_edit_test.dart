import 'dart:async';

import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/presentation/product/core/catalogue_edit.dart';

void main() {
  test('an edit delivers its result once and settles', () async {
    final edit = CatalogueEdit<int>();
    final done = <int>[];
    edit.completed.listen(done.add);

    await edit.run(() async => 7);
    await pumpEventQueue();

    expect(done, [7]);
    expect(edit.state.value.loading, isFalse);
    edit.dispose();
  });

  test('a second tap while the edit is on its way sends nothing', () async {
    final edit = CatalogueEdit<int>();
    final pending = Completer<int>();
    var sent = 0;

    final first = edit.run(() {
      sent++;
      return pending.future;
    });
    await edit.run(() async {
      sent++;
      return 2;
    });
    expect(edit.state.value.loading, isTrue);
    pending.complete(1);
    await first;

    expect(sent, 1, reason: 'the quantity and order dialogs used to send twice');
    edit.dispose();
  });

  test('a failure is explained once, and the dialog can try again', () async {
    final edit = CatalogueEdit<int>();
    final errors = <String>[];
    edit.errors.listen(errors.add);

    await edit.run(() async => throw const ValidationException(message: 'สต็อกไม่พอ'));
    await pumpEventQueue();

    expect(errors.single, contains('สต็อกไม่พอ'));
    expect(edit.state.value.loading, isFalse);
    edit.dispose();
  });
}
