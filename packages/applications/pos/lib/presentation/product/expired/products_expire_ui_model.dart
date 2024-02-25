enum Range {
  expired90Day,
  expired60Day,
  expired30Day,
  today,
  before30Days,
  before60Days,
  before90Days,
  before180Days,
  before240Days,
}

class ListItem {
  Range value;
  String name;

  ListItem(
    this.value,
    this.name,
  );
}
