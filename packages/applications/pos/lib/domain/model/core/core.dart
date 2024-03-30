// Project imports:
import 'package:pos/domain/model/product/product.dart';

class ItemType {
  final String name;
  final String type;
  final String? description;

  ItemType({
    required this.name,
    required this.type,
    this.description,
  });
}

List<ItemType> customerTypes = [
  ItemType(name: "ลูกค้าทั่วไป", type: "General"),
  ItemType(name: "ลูกค้าขายส่ง", type: "Wholesaler"),
  ItemType(name: "ลูกค้าประจำ", type: "Regular"),
];


ItemType findCustomerType(String type) {
  return customerTypes.firstWhere(
        (element) => element.type.toLowerCase() == type.toLowerCase(),
    orElse: () => customerTypes.first,
  );
}

List<ItemType> categoryTypes = [
  ItemType(name: "ไม่ระบุประเภท", type: "None"),
  ItemType(name: "ยารักษาโรค", type: "Medicine"),
  ItemType(name: "ผลิตภัณฑ์เสริมอาหาร", type: "DietarySupplement"),
  ItemType(name: "ผลิตภัณฑ์เสริมความงาม", type: "BeautyProducts"),
  ItemType(name: "อุปกรณ์ทางการแพทย์", type: "MedicalEquipment"),
  ItemType(name: "อุปกรณ์อื่นๆ", type: "OtherEquipment"),
  ItemType(name: "อาหาร/เครื่องดื่ม", type: "FoodDrink"),
  ItemType(name: "สินค้าต้นทุน/โฆษณา", type: "CostAdvertising"),
  ItemType(name: "สินค้าอื่นๆ", type: "General"),
];

List<ItemType> volumeUnits = [
  ItemType(name: "มิลลิลิตร (ml)", type: "ml"),
  ItemType(name: "ลิตร (l)", type: "l"),
  ItemType(name: "ซีซี (cc)", type: "cc"),
  ItemType(name: "มิลลิกรัม (mg)", type: "mg"),
  ItemType(name: "มิลกรัม (g)", type: "g"),
];

List<ItemType> reports = [
  ItemType(name: "รายงาน ข.ย.9", type: "report9", description: "รายงานการซื้อยาทุกประเภท"),
  ItemType(name: "รายงาน ข.ย.10", type: "report10", description: "รายงานการขายยาควบคุมพิเศษ"),
  ItemType(name: "รายงาน ข.ย.11", type: "report11", description: "รายงานการขายยาอันตราย"),
];

ItemType findCategoryType(String type) {
  return categoryTypes.firstWhere(
    (element) => element.type.toLowerCase() == type.toLowerCase(),
    orElse: () => categoryTypes.first,
  );
}

enum Mode {
  search,
  list,
}

enum SortProduct {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  costPriceAsc,
  costPriceDesc,
  quantityAsc,
  quantityDesc,
  createdAsc,
  createdDesc,
  serialNoAsc,
  serialNoDesc,
}

class SortItem {
  SortProduct value;
  String name;

  SortItem(
    this.value,
    this.name,
  );
}

final dropdownItems = [
  SortItem(SortProduct.createdAsc, "Created: Old to New"),
  SortItem(SortProduct.createdDesc, "Created: New to Old"),
  SortItem(SortProduct.nameAsc, "Name: A-Z"),
  SortItem(SortProduct.nameDesc, "Name: Z-A"),
  SortItem(SortProduct.priceAsc, "Price: Low to High"),
  SortItem(SortProduct.priceDesc, "Price: High to Low"),
  SortItem(SortProduct.quantityAsc, "Quantity: Low to High"),
  SortItem(SortProduct.quantityDesc, "Quantity: High to Low"),
  SortItem(SortProduct.serialNoAsc, "Serial No.: Low to High"),
  SortItem(SortProduct.serialNoDesc, "Serial No.: High to Low"),
];

List<Product> _sortProduct(SortProduct sort, String category, List<Product> data) {
  final filtered = data.where((element) => element.category == category).toList();
  switch (sort) {
    case SortProduct.nameAsc:
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return filtered;
    case SortProduct.nameDesc:
      filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      return filtered;
    case SortProduct.priceAsc:
      return filtered;
    case SortProduct.priceDesc:
      return filtered;
    case SortProduct.costPriceAsc:
      return filtered;
    case SortProduct.costPriceDesc:
      return filtered;
    case SortProduct.quantityAsc:
      return filtered;
    case SortProduct.quantityDesc:
      return filtered;
    case SortProduct.createdAsc:
      return filtered;
    case SortProduct.createdDesc:
      return filtered.reversed.toList();
    case SortProduct.serialNoAsc:
      return filtered;
    case SortProduct.serialNoDesc:
      return filtered;
  }
}
