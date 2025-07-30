import 'dart:convert';

class TransferBetweenStockLotProductsModel {
  final int productPackingCode;
  final int productCode;
  final int quantity;

  TransferBetweenStockLotProductsModel({
    required this.productPackingCode,
    required this.productCode,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productPackingCode': productPackingCode,
      'productCode': productCode,
      'quantity': quantity,
    };
  }

  factory TransferBetweenStockLotProductsModel.fromMap(
      Map<String, dynamic> map) {
    return TransferBetweenStockLotProductsModel(
      productPackingCode: map['productPackingCode'] as int,
      productCode: map['productCode'] as int,
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransferBetweenStockLotProductsModel.fromJson(String source) =>
      TransferBetweenStockLotProductsModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  TransferBetweenStockLotProductsModel copyWith({
    int? productPackingCode,
    int? productCode,
    int? quantity,
  }) {
    return TransferBetweenStockLotProductsModel(
      productPackingCode: productPackingCode ?? this.productPackingCode,
      productCode: productCode ?? this.productCode,
      quantity: quantity ?? this.quantity,
    );
  }
}
