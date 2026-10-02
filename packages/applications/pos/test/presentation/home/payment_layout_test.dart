import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/theme/theme.dart';
import 'package:pos/presentation/home/main/payment_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Sarabun')
      ..addFont(
          rootBundle.load('packages/common/assets/font/Sarabun-Regular.ttf'));
    await loader.load();
  });
  for (final size in [const Size(640, 600), const Size(351, 600)]) {
    for (final dark in [false, true]) {
      testWidgets('payment fits $size dark=$dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
          theme: dark ? CustomTheme.darkTheme : CustomTheme.mainTheme,
          home: Scaffold(
              body: PaymentScreen(
                  amount: 1234.50, onCompleted: (_, __) {}, onError: () {})),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('compact payment submits entered amount and selected method',
      (tester) async {
    tester.view.physicalSize = const Size(351, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    double? received;
    String? method;
    await tester.pumpWidget(MaterialApp(
      theme: CustomTheme.darkTheme,
      home: Scaffold(
          body: PaymentScreen(
        amount: 1234.50,
        onCompleted: (amount, type) {
          received = amount;
          method = type;
        },
        onError: () => fail('Valid payment was rejected'),
      )),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('พร้อมเพย์'));
    for (final digit in ['2', '0', '0', '0']) {
      await tester.tap(find.byKey(Key('btn_$digit')));
      await tester.pump();
    }
    await tester.tap(find.byType(ElevatedButton));
    expect(received, 2000);
    expect(method, 'PromptPay');
    expect(tester.takeException(), isNull);
  });
}
