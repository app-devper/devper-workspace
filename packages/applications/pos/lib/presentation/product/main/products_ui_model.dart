enum Mode {
  SEARCH,
  LIST,
}

enum SortProduct {
  NameAsc,
  NameDesc,
  PriceAsc,
  PriceDesc,
  CostPriceAsc,
  CostPriceDesc,
  QuantityAsc,
  QuantityDesc,
  CreatedAsc,
  CreatedDesc,
  SerialNoAsc,
  SerialNoDesc,
}

class ListItem {
  SortProduct value;
  String name;

  ListItem(
    this.value,
    this.name,
  );
}
