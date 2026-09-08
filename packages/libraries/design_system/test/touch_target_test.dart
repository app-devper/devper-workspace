import 'package:design_system/theme/spacing.dart';
import 'package:design_system/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the theme gives every IconButton the minimum tappable box',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: CustomTheme.mainTheme,
      home: Scaffold(
        body: Center(
          child: IconButton(
            icon: const Icon(Icons.tune, size: 18),
            onPressed: () {},
          ),
        ),
      ),
    ));

    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
    expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
  });

  testWidgets('a small icon inside a constrained box still reaches the floor',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: CustomTheme.mainTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.tune, size: 18),
              onPressed: () {},
            ),
          ),
        ),
      ),
    ));

    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, AppSpacing.minTouchTarget);
    expect(size.height, AppSpacing.minTouchTarget);
  });
}
