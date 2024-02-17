class Category {
  final String id;
  final String name;
  final String value;
  final String description;
  final bool isDefault;
  final bool requireCustomerOrder;

  Category({
    required this.id,
    required this.name,
    required this.value,
    required this.description,
    required this.isDefault,
    required this.requireCustomerOrder,
  });
}
