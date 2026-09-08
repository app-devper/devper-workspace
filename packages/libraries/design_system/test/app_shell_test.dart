import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/theme.dart';
import 'package:design_system/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brand in ['Devper POS', 'Devper SM']) {
    testWidgets('$brand shares collapsible navigation', (tester) async {
      tester.view.resetPhysicalSize();
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? selected;
      await tester.pumpWidget(MaterialApp(home: AppShell(
        title: 'Workspace', brand: brand, selectedId: 'one',
        items: const [AppShellItem(id: 'one', label: 'Overview', icon: Icons.home_outlined)],
        onSelect: (id) => selected = id, child: const Text('Content'),
      )));
      await tester.tap(find.text('Overview'));
      expect(selected, 'one');
      await tester.tap(find.byTooltip('ย่อเมนู'));
      await tester.pumpAndSettle();
      expect(find.text('Overview'), findsNothing);
      expect(find.text('Content'), findsOneWidget);
      await tester.tap(find.byTooltip('ขยายเมนู'));
      await tester.pumpAndSettle();
      expect(find.text('Overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('mobile starts closed even when desktop starts expanded', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: AppShell(
      title: 'Workspace', brand: 'Devper', selectedId: 'one', initiallyExpanded: true,
      items: const [AppShellItem(id: 'one', label: 'Overview', icon: Icons.home_outlined)],
      onSelect: (_) {}, child: const Text('Content'),
    )));
    expect(tester.getTopLeft(find.text('Overview')).dx, lessThan(0));
    await tester.tap(find.byTooltip('เมนู'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Overview')).dx, greaterThan(0));
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Overview')).dx, lessThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the sidebar takes its colours from the theme, not the brightness',
      (tester) async {
    Future<Color> panelColour(ThemeMode mode) async {
      await tester.pumpWidget(MaterialApp(
        theme: CustomTheme.mainTheme,
        darkTheme: CustomTheme.darkTheme,
        themeMode: mode,
        home: AppShell(
          title: 'Workspace',
          brand: 'Devper',
          selectedId: 'one',
          items: const [
            AppShellItem(id: 'one', label: 'Overview', icon: Icons.home_outlined)
          ],
          onSelect: (_) {},
          child: const Text('Content'),
        ),
      ));
      await tester.pumpAndSettle();
      // The sidebar is the Container wrapping the brand label, not the top
      // bar, which is also a decorated Container.
      final panel = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Devper'),
              matching: find.byType(Container),
            )
            .last,
      );
      return (panel.decoration! as BoxDecoration).color!;
    }

    final light = await panelColour(ThemeMode.light);
    final dark = await panelColour(ThemeMode.dark);

    expect(light, AppColors.light.sidebarSurface);
    expect(dark, AppColors.dark.sidebarSurface);
    expect(light, isNot(dark));
  });

}
