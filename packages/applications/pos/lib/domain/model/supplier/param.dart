class SupplierParam {
  final String name;
  final String address;
  final String phone;
  final String taxId;

  SupplierParam({
    required this.name,
    required this.address,
    required this.phone,
    required this.taxId,
  });
}

class SupplierUpdateParam {
  final String supplierId;
  final SupplierParam param;

  SupplierUpdateParam({
    required this.supplierId,
    required this.param,
  });
}
