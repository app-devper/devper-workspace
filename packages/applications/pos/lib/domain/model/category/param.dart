class CategoryParam {
  final String name;
  final String value;
  final bool requireCustomerOrder;
  final String? description;

  CategoryParam({
    required this.name,
    required this.value,
    required this.requireCustomerOrder,
    this.description,
  });
}

class CategoryUpdateParam {
  final String categoryId;
  final CategoryParam param;

  CategoryUpdateParam({
    required this.categoryId,
    required this.param,
  });
}
