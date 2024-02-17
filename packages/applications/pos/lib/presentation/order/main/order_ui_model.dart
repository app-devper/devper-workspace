enum Range {
  Today,
  Yesterday,
  Last7Days,
  Last30Days,
  CurrentMonth,
  LastMonth,
  DateRange,
  Date,
  Month,
}

enum Filter {
  All,
  Cash,
  Online,
}

class ListItem {
  Range value;
  String name;

  ListItem(
    this.value,
    this.name,
  );
}
