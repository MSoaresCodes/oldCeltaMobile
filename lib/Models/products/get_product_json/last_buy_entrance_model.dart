class LastBuyEntranceModel {
  String? number;
  String? entranceDate;
  String? supplier;
  double? quantity;
  String? fiscalCode;
  String? Packing;

  LastBuyEntranceModel({
    required this.number,
    required this.entranceDate,
    required this.supplier,
    required this.quantity,
    required this.fiscalCode,
    required this.Packing,
  });

  LastBuyEntranceModel.fromJson(Map<String, dynamic> json) {
    number = json['Number'];
    entranceDate = json['EntranceDate'];
    supplier = json['Supplier'];
    quantity = json['Quantity'];
    fiscalCode = json['FiscalCode'];
    Packing = json['Packing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Number'] = this.number;
    data['EntranceDate'] = this.entranceDate;
    data['Supplier'] = this.supplier;
    data['Quantity'] = this.quantity;
    data['FiscalCode'] = this.fiscalCode;
    data['Packing'] = this.Packing;
    return data;
  }
}
