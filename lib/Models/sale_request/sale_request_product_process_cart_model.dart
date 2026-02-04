import '../../Models/models.dart';

class SaleRequestProductProcessCartModel {
  int? ProductPackingCode;
  double? Quantity;
  double? Value;
  double? TotalLiquid;
  String? IncrementPercentageOrValue; //"R$"" ou "%"
  double? IncrementValue;
  String? DiscountPercentageOrValue; //"R$"" ou "%"
  double? DiscountValue;
  String? DiscountDescription;
  String? AutomaticDiscountPercentageOrValue; //"R$"" ou "%"
  double? AutomaticDiscountValue;
  String? ExpectedDeliveryDate;
  String? Observations;

  SaleRequestProductProcessCartModel({
    required this.ProductPackingCode,
    required this.AutomaticDiscountPercentageOrValue,
    required this.AutomaticDiscountValue,
    required this.TotalLiquid,
    required this.Quantity,
    required this.Value,
    required this.IncrementPercentageOrValue,
    required this.IncrementValue,
    required this.DiscountPercentageOrValue,
    required this.DiscountValue,
    required this.DiscountDescription,
    required this.ExpectedDeliveryDate,
    required this.Observations,
  });

  static List<Map<String, dynamic>> cartProductsToProcessCart(
    List<GetProductJsonModel> cartProducts,
  ) {
    return cartProducts
        .map((e) => {
              "ProductPackingCode": e.productPackingCode,
              "Quantity": e.quantity,
              "Value": e.value,
              "TotalLiquid": e.quantity * e.value!,
              "IncrementPercentageOrValue": e.IncrementPercentageOrValue ?? 0,
              "IncrementValue": e.IncrementValue ?? 0,
              "DiscountPercentageOrValue": 0,
              "DiscountValue": 0,
              "AutomaticDiscountPercentageOrValue":
                  e.AutomaticDiscountPercentageOrValue ?? 0,
              "AutomaticDiscountValue": e.AutomaticDiscountValue ?? 0,
              "Name": 'any',
            })
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "ProductPackingCode": ProductPackingCode,
      "AutomaticDiscountPercentageOrValue": AutomaticDiscountPercentageOrValue,
      "AutomaticDiscountValue": AutomaticDiscountValue ?? 0,
      "TotalLiquid": TotalLiquid,
      "Quantity": Quantity,
      "Value": Value,
      "IncrementPercentageOrValue": IncrementPercentageOrValue,
      "IncrementValue": IncrementValue,
      "DiscountPercentageOrValue": DiscountPercentageOrValue,
      "DiscountValue": DiscountValue,
      "DiscountDescription": DiscountDescription,
      "ExpectedDeliveryDate": DateTime.now().toIso8601String(),
      "Observations": Observations,
    };
  }

  factory SaleRequestProductProcessCartModel.fromJson(
      Map<String, dynamic> json) {
    return SaleRequestProductProcessCartModel(
      ProductPackingCode: json['ProductPackingCode'],
      Quantity: json['Quantity'],
      Value: json['Value'],
      IncrementValue: json['IncrementValue'],
      DiscountValue: json['DiscountValue'],
      DiscountDescription: json["DiscountDescription"] ?? "",
      AutomaticDiscountValue: json["AutomaticDiscountValue"] ?? 0,
      TotalLiquid: json["TotalLiquid"],
      ExpectedDeliveryDate: json['ExpectedDeliveryDate'],
      Observations: json["Observations"],
      IncrementPercentageOrValue: json["IncrementPercentageOrValue"],
      DiscountPercentageOrValue: json["DiscountPercentageOrValue"],
      AutomaticDiscountPercentageOrValue:
          json["AutomaticDiscountPercentageOrValue"],
    );
  }

  factory SaleRequestProductProcessCartModel.fromGetProductJsonModel(
          GetProductJsonModel product) =>
      SaleRequestProductProcessCartModel(
        ProductPackingCode: product.productPackingCode,
        AutomaticDiscountPercentageOrValue:
            product.AutomaticDiscountPercentageOrValue,
        AutomaticDiscountValue: product.AutomaticDiscountValue ?? 0,
        TotalLiquid: product.TotalLiquid ?? product.quantity * product.value!,
        Quantity: product.quantity,
        Value: product.value,
        IncrementPercentageOrValue: product.IncrementPercentageOrValue,
        IncrementValue: product.IncrementValue,
        DiscountPercentageOrValue: product.DiscountPercentageOrValue,
        DiscountValue: product.DiscountValue ?? 0,
        DiscountDescription: product.DiscountDescription,
        ExpectedDeliveryDate: null,
        Observations: null,
      );
}
