class RequestDrugInfo {
  final String? genericName;
  final String? drugType;
  final String? dosageForm;
  final String? strength;
  final String? indication;
  final String? dosage;
  final String? sideEffects;
  final String? contraindications;
  final String? storageCondition;
  final String? manufacturer;
  final String? registrationNo;
  final bool? isControlled;
  final List<String>? drugInteractions;

  RequestDrugInfo({
    this.genericName,
    this.drugType,
    this.dosageForm,
    this.strength,
    this.indication,
    this.dosage,
    this.sideEffects,
    this.contraindications,
    this.storageCondition,
    this.manufacturer,
    this.registrationNo,
    this.isControlled,
    this.drugInteractions,
  });
}
