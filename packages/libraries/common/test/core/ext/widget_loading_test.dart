import 'package:common/core/error/exception.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('a failed future explains itself instead of rendering blank',
      (tester) async {
    // Thrown from inside the future so the test zone does not see it as an
    // unhandled error before FutureBuilder subscribes.
    final future = Future<List<String>>.delayed(
      Duration.zero,
      () => throw const NetworkException(message: 'down', code: 'NETWORK_ERROR'),
    );

    await tester.pumpWidget(host(
      future.toWidgetLoading(widgetBuilder: (data) => const Text('list')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('list'), findsNothing);
    expect(find.text('โหลดข้อมูลไม่สำเร็จ'), findsOneWidget);
    expect(find.textContaining('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้'), findsOneWidget);
  });

  testWidgets('retry is offered only when the caller can rebuild the future',
      (tester) async {
    Future<List<String>> failing() => Future<List<String>>.delayed(
          Duration.zero,
          () => throw const ServerException(message: 'boom', code: 'SERVER_ERROR'),
        );

    await tester.pumpWidget(host(
      failing().toWidgetLoading(widgetBuilder: (data) => const Text('list')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('ลองใหม่'), findsNothing);

    var retries = 0;
    await tester.pumpWidget(host(
      failing().toWidgetLoading(
        widgetBuilder: (data) => const Text('list'),
        onRetry: () => retries++,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ลองใหม่'), findsOneWidget);
    await tester.tap(find.text('ลองใหม่'));
    expect(retries, 1);
  });

  testWidgets('a resolved future still renders the content', (tester) async {
    await tester.pumpWidget(host(
      Future.value(['a']).toWidgetLoading(
        widgetBuilder: (data) => Text('items ${data.length}'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('items 1'), findsOneWidget);
  });
}
