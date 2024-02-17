class Product {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final double price;
  final double costPrice;
  final String unit;
  final int quantity;
  final String serialNumber;
  final String category;
  final String createdDate;

  Product({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    required this.price,
    required this.costPrice,
    required this.unit,
    required this.quantity,
    required this.serialNumber,
    required this.category,
    required this.createdDate,
  });
}
