class CustomerParam {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String customerType;

  CustomerParam({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.customerType,
  });
}

class CustomerUpdateParam {
  final String customerId;
  final CustomerParam param;

  CustomerUpdateParam({
    required this.customerId,
    required this.param,
  });
}
