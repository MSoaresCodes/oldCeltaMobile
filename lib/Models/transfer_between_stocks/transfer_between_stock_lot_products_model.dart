// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../models.dart';

class TransferBetweenStockLotProductsModel {
  final GetProductJsonModel product;
  final double quantity;
  final GetJustificationsModel justification;
  final GetStockTypesModel originStock;
  final GetStockTypesModel destinyStock;

  TransferBetweenStockLotProductsModel({
    required this.product,
    required this.quantity,
    required this.justification,
    required this.originStock,
    required this.destinyStock,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product': product.toJson(),
      'quantity': quantity,
      'justification': justification.toJson(),
      'originStock': originStock.toJson(),
      'destinyStock': destinyStock.toJson(),
    };
  }

  factory TransferBetweenStockLotProductsModel.fromMap(
      Map<String, dynamic> map) {
    return TransferBetweenStockLotProductsModel(
      product:
          GetProductJsonModel.fromJson(map['product'] as Map<String, dynamic>),
      quantity: map['quantity'] as double,
      justification: GetJustificationsModel.fromJson(map['justification']),
      destinyStock: GetStockTypesModel.fromJson(map['destinyStock']),
      originStock: GetStockTypesModel.fromJson(map['originStock']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TransferBetweenStockLotProductsModel.fromJson(String source) =>
      TransferBetweenStockLotProductsModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  TransferBetweenStockLotProductsModel copyWith({
    GetProductJsonModel? product,
    double? quantity,
    GetJustificationsModel? justification,
    GetStockTypesModel? originStock,
    GetStockTypesModel? destinyStock,
  }) {
    return TransferBetweenStockLotProductsModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      justification: justification ?? this.justification,
      originStock: originStock ?? this.originStock,
      destinyStock: destinyStock ?? this.destinyStock,
    );
  }
}
