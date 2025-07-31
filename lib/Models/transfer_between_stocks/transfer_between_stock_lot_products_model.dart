// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../models.dart';

class TransferBetweenStockLotProductsModel {
  final GetProductJsonModel product;
  final double quantity;
  //TODO add justification, stockOrigin and destinyStock

  TransferBetweenStockLotProductsModel({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory TransferBetweenStockLotProductsModel.fromMap(
      Map<String, dynamic> map) {
    return TransferBetweenStockLotProductsModel(
      product:
          GetProductJsonModel.fromJson(map['product'] as Map<String, dynamic>),
      quantity: map['quantity'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransferBetweenStockLotProductsModel.fromJson(String source) =>
      TransferBetweenStockLotProductsModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  TransferBetweenStockLotProductsModel copyWith({
    GetProductJsonModel? product,
    double? quantity,
  }) {
    return TransferBetweenStockLotProductsModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
