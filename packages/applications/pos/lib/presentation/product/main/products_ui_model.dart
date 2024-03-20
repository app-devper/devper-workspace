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

class ListItem {
  SortProduct value;
  String name;

  ListItem(
    this.value,
    this.name,
  );
}
