// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Project imports:
import 'package:pos/domain/model/category/category.dart';

/// What this screen renders: the category options, and whether a save is in
/// flight.
///
/// The created product and the generated serial number used to sit here behind
/// a sealed task. One returns to the caller, the other fills a field — both
/// happen once — so both go on the event channel.
@immutable
class ProductAddState {
  final bool saving;
  final List<Category> categories;

  const ProductAddState({
    this.saving = false,
    this.categories = const [],
  });

  ProductAddState copyWith({
    bool? saving,
    List<Category>? categories,
  }) {
    return ProductAddState(
      saving: saving ?? this.saving,
      categories: categories ?? this.categories,
    );
  }
}
