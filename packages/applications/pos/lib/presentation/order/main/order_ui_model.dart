enum Range {
  today,
  yesterday,
  last7Days,
  last30Days,
  currentMonth,
  lastMonth,
  dateRange,
  date,
  month,
}

enum Filter {
  all,
  cash,
  online,
}

class ListItem {
  Range value;
  String name;

  ListItem(
    this.value,
    this.name,
  );
}
