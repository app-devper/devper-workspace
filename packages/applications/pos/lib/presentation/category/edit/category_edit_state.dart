// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';

/// The mutually exclusive states of this screen's two commands.
///
/// Saving and deleting share the screen but not a slot: an update result and a
/// delete result can never both be present, which is what the four independent
/// nullable fields used to allow.
sealed class CategoryEditState {
  const CategoryEditState._();
  const factory CategoryEditState() = CategoryEditIdle;

  // Derived UI projections; no independently writable flags.
  bool get loading =>
      this is CategoryEditSaving || this is CategoryEditDeleting;
  String? get error => switch (this) {
        CategoryEditFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Category? get updated => switch (this) {
        CategoryEditUpdated(:final category) => category,
        _ => null,
      };
  Category? get removed => switch (this) {
        CategoryEditRemoved(:final category) => category,
        _ => null,
      };
}

final class CategoryEditIdle extends CategoryEditState {
  const CategoryEditIdle() : super._();
}

final class CategoryEditSaving extends CategoryEditState {
  const CategoryEditSaving() : super._();
}

final class CategoryEditDeleting extends CategoryEditState {
  const CategoryEditDeleting() : super._();
}

final class CategoryEditUpdated extends CategoryEditState {
  final Category category;
  const CategoryEditUpdated(this.category) : super._();
}

final class CategoryEditRemoved extends CategoryEditState {
  final Category category;
  const CategoryEditRemoved(this.category) : super._();
}

final class CategoryEditFailed extends CategoryEditState {
  final Failure failure;
  const CategoryEditFailed(this.failure) : super._();
}
