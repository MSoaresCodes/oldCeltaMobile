class SoapActionsModel {
  final String documentId;
  final List<dynamic>? datesUsed;
  final List<dynamic>? users;
  final int? adjustStockConfirmQuantity;
  final int? adjustSalePrice;
  final int? productsConference;
  final int? priceConferenceGetProductOrSendToPrint;
  final int? inventoryEntryQuantity;
  final int? receiptEntryQuantity;
  final int? receiptLiberate;
  final int? saleRequestSave;
  final int? transferBetweenStocksConfirmAdjust;
  final int? transferBetweenPackageConfirmAdjust;
  final int? transferRequestSave;
  final int? customerRegister;
  final int? buyRequestSave;
  final int? researchPricesInsertPrice;
  final int? reports;

  SoapActionsModel({
    required this.documentId,
    required this.datesUsed,
    required this.users,
    required this.adjustSalePrice,
    required this.productsConference,
    required this.adjustStockConfirmQuantity,
    required this.priceConferenceGetProductOrSendToPrint,
    required this.inventoryEntryQuantity,
    required this.receiptEntryQuantity,
    required this.receiptLiberate,
    required this.saleRequestSave,
    required this.transferBetweenStocksConfirmAdjust,
    required this.transferBetweenPackageConfirmAdjust,
    required this.transferRequestSave,
    required this.customerRegister,
    required this.buyRequestSave,
    required this.researchPricesInsertPrice,
    required this.reports,
  });

  Map<String, dynamic> toJson() => {
        "documentId": documentId,
        "datesUsed": datesUsed,
        "users": users,
        "adjustSalePrice": adjustSalePrice,
        "productsConference": productsConference,
        "adjustStockConfirmQuantity": adjustStockConfirmQuantity,
        "priceConferenceGetProductOrSendToPrint":
            priceConferenceGetProductOrSendToPrint,
        "inventoryEntryQuantity": inventoryEntryQuantity,
        "receiptEntryQuantity": receiptEntryQuantity,
        "receiptLiberate": receiptLiberate,
        "saleRequestSave": saleRequestSave,
        "transferBetweenStocksConfirmAdjust":
            transferBetweenStocksConfirmAdjust,
        "transferBetweenPackageConfirmAdjust":
            transferBetweenPackageConfirmAdjust,
        "transferRequestSave": transferRequestSave,
        "customerRegister": customerRegister,
        "buyRequestSave": buyRequestSave,
        "researchPricesInsertPrice": researchPricesInsertPrice,
        "reports": reports,
      };

  static int? _sumValueIfHas(Map<String, dynamic>? request) {
    int counter = 0;

    if (request == null) {
      return null;
    } else {
      if (request.containsKey("iOS")) {
        counter += request["iOS"] as int;
      }
      if (request.containsKey("timesUsed")) {
        counter += request["timesUsed"] as int;
      }
      if (request.containsKey("android")) {
        counter += request["android"] as int;
      }
    }

    return counter;
  }

  factory SoapActionsModel.fromJson({
    required String documentId,
    required Map json,
  }) =>
      SoapActionsModel(
        documentId: documentId,
        datesUsed: json["datesUsed"],
        users: json["users"],
        adjustSalePrice: _sumValueIfHas(json["adjustSalePrice"]),
        productsConference: _sumValueIfHas(json["productsConference"]),
        adjustStockConfirmQuantity:
            _sumValueIfHas(json["adjustStockConfirmQuantity"]),
        priceConferenceGetProductOrSendToPrint:
            _sumValueIfHas(json["priceConferenceGetProductOrSendToPrint"]),
        inventoryEntryQuantity: _sumValueIfHas(json["inventoryEntryQuantity"]),
        receiptEntryQuantity: _sumValueIfHas(json["receiptEntryQuantity"]),
        receiptLiberate: _sumValueIfHas(json["receiptLiberate"]),
        saleRequestSave: _sumValueIfHas(json["saleRequestSave"]),
        transferBetweenStocksConfirmAdjust:
            _sumValueIfHas(json["transferBetweenStocksConfirmAdjust"]),
        transferBetweenPackageConfirmAdjust:
            _sumValueIfHas(json["transferBetweenPackageConfirmAdjust"]),
        transferRequestSave: _sumValueIfHas(json["transferRequestSave"]),
        customerRegister: _sumValueIfHas(json["customerRegister"]),
        buyRequestSave: _sumValueIfHas(json["buyRequestSave"]),
        researchPricesInsertPrice:
            _sumValueIfHas(json["researchPricesInsertPrice"]),
        reports: _sumValueIfHas(json["reports"]),
      );
}
