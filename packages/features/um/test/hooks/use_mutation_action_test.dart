import 'dart:async';
import 'package:common/localizations/localizations_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um/hooks/use_mutation_action.dart';

void main() {
  testWidgets('one pending request uses latest success callback after rebuild',
      (tester) async {
    final pending = Completer<int>();
    var calls = 0;
    var callback = 0;
    var version = 1;
    late Future<void> Function(int) execute;
    late StateSetter rebuild;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [CommonLocalizationsDelegate()],
      home: StatefulBuilder(builder: (context, setState) {
        rebuild = setState;
        final current = version;
        return HookBuilder(builder: (context) {
          execute = useMutationAction<int, int>(context, (_) {
            calls++;
            return pending.future;
          }, onSuccess: (_) => callback = current);
          return const Scaffold(body: Text('Home'));
        });
      }),
    ));
    final first = execute(1);
    await tester.pump();
    rebuild(() => version = 2);
    await tester.pump();
    await execute(2);
    expect(calls, 1);
    pending.complete(1);
    await tester.pumpAndSettle();
    await first;
    expect(callback, 2);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completion after unmount never calls success or pops new screen',
      (tester) async {
    final pending = Completer<int>();
    var calls = 0;
    late Future<void> Function(int) execute;
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [CommonLocalizationsDelegate()],
        home: HookBuilder(builder: (context) {
          execute = useMutationAction<int, int>(context, (_) => pending.future,
              onSuccess: (_) => calls++);
          return const Scaffold(body: Text('Original'));
        })));
    final request = execute(1);
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(
        key: ValueKey('replacement'),
        home: Scaffold(body: Text('New screen'))));
    pending.complete(1);
    await tester.pumpAndSettle();
    await request;
    expect(calls, 0);
    expect(find.text('New screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failure closes loader and preserves form for retry',
      (tester) async {
    late Future<void> Function(int) execute;
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [CommonLocalizationsDelegate()],
        home: HookBuilder(builder: (context) {
          execute = useMutationAction<int, int>(
              context, (_) async => throw Exception('offline'),
              onSuccess: (_) {});
          return const Scaffold(body: Text('Form'));
        })));
    final request = execute(1);
    await tester.pumpAndSettle();
    await request;
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Form'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an Error surfaces in the dialog instead of going unhandled',
      (tester) async {
    late Future<void> Function(int) execute;
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [CommonLocalizationsDelegate()],
        home: HookBuilder(builder: (context) {
          execute = useMutationAction<int, int>(
              context, (_) async => throw StateError('bad cast'),
              onSuccess: (_) {});
          return const Scaffold(body: Text('Form'));
        })));
    final request = execute(1);
    await tester.pumpAndSettle();
    await request;
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the loading dialog inherits the theme above its caller',
      (tester) async {
    const dialogBackground = Color(0xFF123456);
    final pending = Completer<int>();
    late Future<void> Function(int) execute;
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [CommonLocalizationsDelegate()],
        home: Theme(
          data: ThemeData(
            dialogTheme:
                const DialogThemeData(backgroundColor: dialogBackground),
          ),
          child: HookBuilder(builder: (context) {
            execute = useMutationAction<int, int>(
                context, (_) => pending.future,
                onSuccess: (_) {});
            return const Scaffold(body: Text('Form'));
          }),
        )));
    final request = execute(1);
    // Not pumpAndSettle: the spinner never stops, so settling times out
    // while the loading dialog is up.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final material = tester.widget<Material>(find
        .descendant(
            of: find.byType(AlertDialog), matching: find.byType(Material))
        .first);
    expect(material.color, dialogBackground);

    pending.complete(1);
    await tester.pumpAndSettle();
    await request;
    expect(tester.takeException(), isNull);
  });
}
