import '../models.dart';

class BuyQuotationProductsModel {
  final int? Code;
  final GetProductJsonModel? Product;
  final List<ProductEnterprise>? ProductEnterprises;

  BuyQuotationProductsModel({
    required this.Code,
    required this.Product,
    required this.ProductEnterprises,
  });

  factory BuyQuotationProductsModel.fromJson(Map data) =>
      BuyQuotationProductsModel(
        Code: data["Code"],
        Product: GetProductJsonModel.fromJson(data["Product"]),
        ProductEnterprises: data["ProductEnterprises"] == null
            ? null
            : (data["ProductEnterprises"] as List)
                .map((e) => ProductEnterprise.fromJson(e))
                .toList(),
      );

  Map<String, dynamic> toJson({required bool isInserting}) => {
        "Code": isInserting ? 0 : Code,
        "Product": Product?.toJson(),
        "ProductEnterprises":
            ProductEnterprises?.map((e) => e.toJson()).toList(),
      };
}

class ProductEnterprise {
  final int? Code;
  final int? EnterpriseCode;
  final double? Quantity;

  const ProductEnterprise({
    required this.Code,
    required this.EnterpriseCode,
    required this.Quantity,
  });

  factory ProductEnterprise.fromJson(Map data) => ProductEnterprise(
        Code: data["Code"],
        EnterpriseCode: data["EnterpriseCode"],
        Quantity: data["Quantity"],
      );

  Map<String, dynamic> toJson() => {
        "Code": Code,
        "EnterpriseCode": EnterpriseCode,
        "Quantity": Quantity,
      };
}
