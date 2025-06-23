class TransferBetweenStockBodyModel {
  final int? EnterpriseCode;
  final int? ProductCode;
  final int? ProductPackingCode;
  final int? JustificationCode;
  final int? StockTypeCode;
  final int? StockTypeRecipientCode;
  final bool? IsPendingAdjust;
  final double? Quantity;

  TransferBetweenStockBodyModel({
    required this.EnterpriseCode,
    required this.ProductCode,
    required this.ProductPackingCode,
    required this.JustificationCode,
    required this.StockTypeCode,
    required this.StockTypeRecipientCode,
    required this.IsPendingAdjust,
    required this.Quantity,
  });

  Map<String, dynamic> toJson() => {
        "EnterpriseCode": EnterpriseCode,
        "ProductCode": ProductCode,
        "ProductPackingCode": ProductPackingCode,
        "JustificationCode": JustificationCode,
        "StockTypeCode": StockTypeCode,
        "StockTypeRecipientCode": StockTypeRecipientCode,
        "IsPendingAdjust": IsPendingAdjust,
        "Quantity": Quantity,
      };
}
