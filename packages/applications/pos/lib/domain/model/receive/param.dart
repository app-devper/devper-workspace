class ReceiveParam {
  final String supplierId;
  final String reference;

  ReceiveParam({
    required this.supplierId,
    required this.reference,
  });
}

class UpdateReceiveParam {
  final String supplierId;
  final String reference;
  final double totalCost;

  UpdateReceiveParam({
    required this.supplierId,
    required this.reference,
    required this.totalCost,
  });
}

class ReceiveUpdateParam {
  final String receiveId;
  final UpdateReceiveParam param;

  ReceiveUpdateParam({
    required this.receiveId,
    required this.param,
  });
}

class GetReceivesRangeParam {
  final String startDate;
  final String endDate;

  GetReceivesRangeParam({
    required this.startDate,
    required this.endDate,
  });
}
