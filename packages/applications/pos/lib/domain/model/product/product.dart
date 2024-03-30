// Project imports:
import 'package:pos/domain/model/core/core.dart';

class Product {
  final String id;
  String name;
  String? nameEn;
  String? description;
  String category;
  String createdDate;
  List<ProductUnit> units;
  List<ProductPrice> prices;
  List<ProductStock> stocks;

  Product({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    required this.category,
    required this.createdDate,
    required this.units,
    required this.prices,
    required this.stocks,
  });

  List<ProductUnitItem> toProductItems() {
    final items = <ProductUnitItem>[];
    for (var unit in units) {
      final prices = getProductPricesUnit(unit.id);
      final stocks = getProductStocksUnit(unit.id);
      items.add(ProductUnitItem(
        id: id,
        name: name,
        nameEn: nameEn,
        description: description,
        category: category,
        createdDate: createdDate,
        unit: unit,
        prices: prices,
        stocks: stocks,
      ));
    }
    return items;
  }

  int getQuantity() {
    return stocks.fold(0, (previousValue, stock) => previousValue + stock.quantity);
  }

  int getQuantityByUnit(String unitId) {
    return stocks.where((element) => element.unitId == unitId).fold(0, (previousValue, stock) => previousValue + stock.quantity);
  }

  List<ProductPrice> getProductPricesUnit(String unitId) {
    return prices.where((element) => element.unitId == unitId).toList();
  }

  ProductPrice getDefaultPriceUnit(String unitId) {
    return prices.where((element) => element.unitId == unitId && element.customerType == "General").first;
  }

  List<ProductStock> getProductStocksUnit(String unitId) {
    final items = stocks.where((element) => element.unitId == unitId).toList();
    items.sort((a, b) => a.sequence.compareTo(b.sequence));
    return items;
  }
}

class ProductUnitItem {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String category;
  final String createdDate;
  final ProductUnit unit;
  final List<ProductPrice> prices;
  List<ProductStock> stocks;

  ProductUnitItem({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    required this.category,
    required this.createdDate,
    required this.unit,
    required this.prices,
    required this.stocks,
  });

  ProductPriceType getPrice(String customerType) {
    final stock = getFirstSequenceStock();
    if (customerType == "Stock") {
      if (stock != null && stock.price > 0) {
        return ProductPriceType(
          stock: stock,
          type: "Stock",
          price: stock.price,
          costPrice: stock.costPrice > 0 ? stock.costPrice : unit.costPrice,
        );
      }
    }
    if (prices.isNotEmpty) {
      final price = prices.where((element) => element.customerType == customerType).firstOrNull;
      if (price != null) {
        return ProductPriceType(stock: stock, type: price.customerType, price: price.price, costPrice: stock != null && stock.costPrice > 0 ? stock.costPrice : unit.costPrice);
      } else {
        return ProductPriceType(
          stock: stock,
          type: prices.first.customerType,
          price: prices.first.price,
          costPrice: stock != null && stock.costPrice > 0 ? stock.costPrice : unit.costPrice,
        );
      }
    } else {
      return ProductPriceType(
        stock: stock,
        type: "",
        price: 0,
        costPrice: stock != null && stock.costPrice > 0 ? stock.costPrice : unit.costPrice,
      );
    }
  }

  ProductStock? getFirstSequenceStock() {
    stocks.sort((a, b) => a.sequence.compareTo(b.sequence));

    for (var element in stocks) {
      if (element.quantity > 0) {
        return element;
      }
    }
    return null;
  }

  int getQuantity() {
    return stocks.fold(0, (previousValue, stock) => previousValue + stock.quantity);
  }

  void updateProductStockSequence(List<ProductStock> items) {
    stocks = items;
  }

  ProductStock? getProductStockById(String stockId) {
    return stocks.where((element) => element.id == stockId).firstOrNull;
  }
}

class ProductPriceType {
  final ProductStock? stock;
  final String type;
  final double price;
  final double costPrice;

  ProductPriceType({
    required this.stock,
    required this.type,
    required this.price,
    required this.costPrice,
  });
}

class ProductStock {
  final String id;
  final String unitId;
  final String productId;
  String receiveCode;
  int sequence;
  String lotNumber;
  double costPrice;
  double price;
  final int import;
  int quantity;
  String expireDate;
  String importDate;

  ProductStock({
    required this.id,
    required this.unitId,
    required this.productId,
    required this.receiveCode,
    required this.sequence,
    required this.lotNumber,
    required this.costPrice,
    required this.price,
    required this.import,
    required this.quantity,
    required this.expireDate,
    required this.importDate,
  });
}

class ProductPrice {
  final String id;
  final String productId;
  final String unitId;
  String customerType;
  double price;

  ProductPrice({
    required this.id,
    required this.productId,
    required this.unitId,
    required this.customerType,
    required this.price,
  });

  String getCustomerTypePrice() {
    switch (customerType) {
      case "General":
        return "ราคาหน้าร้าน";
      case "Regular":
        return "ลูกค้าประจำ";
      case "Wholesaler":
        return "ราคาขายส่ง";
      default:
        return "ไม่มีราคา";
    }
  }

  String getCustomerTypeDisplay() {
    final customerType = customerTypes.firstWhere(
      (element) => element.type == this.customerType,
      orElse: () => ItemType(name: "-", type: ""),
    );
    return customerType.name;
  }
}

class ProductUnit {
  final String id;
  final String productId;
  String unit;
  double costPrice;
  int size;
  String barcode;
  double volume;
  String volumeUnit;

  ProductUnit({
    required this.id,
    required this.productId,
    required this.costPrice,
    required this.unit,
    required this.size,
    required this.barcode,
    required this.volume,
    required this.volumeUnit,
  });
}
