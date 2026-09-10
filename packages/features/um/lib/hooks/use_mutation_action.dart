import 'package:common/core/error/failure.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum MutationLifecycle { idle, running, disposed }

/// Presentation-only adapter. The injected action owns the application logic.
/// Owns exactly one loading route; never pops an unrelated page on completion.
Future<void> Function(P) useMutationAction<P, R>(
  BuildContext context,
  Future<R> Function(P) action, {
  required void Function(R) onSuccess,
}) {
  final currentAction = useRef(action)..value = action;
  final currentSuccess = useRef(onSuccess)..value = onSuccess;
  final lifecycle = useRef(MutationLifecycle.idle);
  final loadingRoute = useRef<DialogRoute<void>?>(null);

  void closeLoading() {
    final route = loadingRoute.value;
    loadingRoute.value = null;
    final navigator = route?.navigator;
    if (route != null &&
        route.isActive &&
        navigator != null &&
        navigator.mounted) {
      navigator.removeRoute(route);
    }
  }

  useEffect(() {
    lifecycle.value = MutationLifecycle.idle;
    return () {
      lifecycle.value = MutationLifecycle.disposed;
      // Disposal can run while Navigator is updating its route stack.
      WidgetsBinding.instance.addPostFrameCallback((_) => closeLoading());
    };
  }, const []);

  return useCallback((P param) async {
    if (lifecycle.value != MutationLifecycle.idle || !context.mounted) return;
    lifecycle.value = MutationLifecycle.running;
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      // showDialog captures the inherited themes before handing the child to
      // the root navigator; a hand-rolled DialogRoute has to do the same or
      // any Theme between MaterialApp and the caller is lost inside it.
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      builder: (context) => const LoadingDialog(),
    );
    loadingRoute.value = route;
    navigator.push(route);

    Failure? failure;
    late R result;
    try {
      result = await currentAction.value(param);
    } catch (error) {
      // Not `on Exception`: a bad cast or a failed assertion throws an Error,
      // and swallowing those left the caller staring at a screen that never
      // reported anything.
      failure = toFailure(error);
    } finally {
      closeLoading();
      if (lifecycle.value != MutationLifecycle.disposed) {
        lifecycle.value = MutationLifecycle.idle;
      }
    }
    if (lifecycle.value == MutationLifecycle.disposed || !context.mounted) {
      return;
    }
    if (failure != null) {
      showAlertDialog(context, failure.getMessage(), () {});
      return;
    }
    // Outside the try: an exception thrown by the success callback is a bug in
    // the caller, not a failed request, and must not raise the error dialog.
    currentSuccess.value(result);
  }, [context]);
}
