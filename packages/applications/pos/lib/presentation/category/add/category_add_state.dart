// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class CategoryAddTask {
  const CategoryAddTask._();
  const factory CategoryAddTask() = CategoryAddIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is CategoryAddRunning;
  String? get error => switch (this) {
        CategoryAddFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Category? get created => switch (this) {
        CategoryAddCreated(:final result) => result,
        _ => null,
      };
}

final class CategoryAddIdle extends CategoryAddTask {
  const CategoryAddIdle() : super._();
}

final class CategoryAddRunning extends CategoryAddTask {
  const CategoryAddRunning() : super._();
}

final class CategoryAddCreated extends CategoryAddTask {
  final Category result;
  const CategoryAddCreated(this.result) : super._();
}

final class CategoryAddFailed extends CategoryAddTask {
  final Failure failure;
  const CategoryAddFailed(this.failure) : super._();
}

@immutable
class CategoryAddState {
  final CategoryAddTask task;

  const CategoryAddState({
    this.task = const CategoryAddIdle(),
  });

  bool get saving => task.running;

  String? get error => task.error;

  Category? get created => task.created;

  CategoryAddState copyWith({
    CategoryAddTask? task,
  }) {
    return CategoryAddState(
      task: task ?? this.task,
    );
  }
}
