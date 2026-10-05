import 'package:design_system/theme/theme.dart';
import 'package:design_system/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('compact dialog header has accessible actions dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(288, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var closed = false;
      var saved = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? CustomTheme.darkTheme : CustomTheme.mainTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: TitleBar(
              title: 'รายละเอียดสินค้าที่มีชื่อยาวมาก',
              action: 'บันทึก',
              onBack: () => closed = true,
              onAction: () => saved = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final button in find.byType(TextButton).evaluate()) {
        expect(
          tester.getSize(find.byWidget(button.widget)).height,
          greaterThanOrEqualTo(48),
        );
      }
      await tester.tap(find.text('บันทึก'));
      await tester.tap(find.text('ปิด'));
      expect(saved, isTrue);
      expect(closed, isTrue);
    });
  }
}
