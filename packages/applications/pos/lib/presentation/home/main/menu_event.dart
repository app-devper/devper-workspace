enum MenuEvent {
  home,
  order,
  product,
  database,
  customer,
  receive,
  setting,
}

bool isDatabaseMenu(MenuEvent menuEvent) {
  return menuEvent == MenuEvent.database || menuEvent == MenuEvent.customer || menuEvent == MenuEvent.receive;
}
