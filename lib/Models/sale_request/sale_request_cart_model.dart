// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models.dart';

class SaleRequestCartModel {
  final List<GetProductJsonModel>? cartProducts;
  final CustomerModel? selectedCustomer;
  final String? lastSaleRequestSaved;
  final String enterpriseCode;

  SaleRequestCartModel({
    required this.cartProducts,
    required this.selectedCustomer,
    required this.lastSaleRequestSaved,
    required this.enterpriseCode,
  });

  SaleRequestCartModel copyWith({
    List<GetProductJsonModel>? cartProducts,
    CustomerModel? selectedCustomer,
    String? lastSaleRequestSaved,
    String? enterpriseCode,
  }) {
    return SaleRequestCartModel(
      cartProducts: cartProducts ?? this.cartProducts,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      lastSaleRequestSaved: lastSaleRequestSaved ?? this.lastSaleRequestSaved,
      enterpriseCode: enterpriseCode ?? this.enterpriseCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cartProducts': cartProducts?.map((x) => x.toJson()).toList(),
      'selectedCustomer': selectedCustomer?.toJson(),
      'lastSaleRequestSaved': lastSaleRequestSaved,
      'enterpriseCode': enterpriseCode,
    };
  }

  factory SaleRequestCartModel.fromMap(Map<String, dynamic> map) {
    return SaleRequestCartModel(
      cartProducts: List<GetProductJsonModel>.from(
        (map['cartProducts'] as List).map<GetProductJsonModel>(
          (x) => GetProductJsonModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
      selectedCustomer: map['selectedCustomer'] != null
          ? CustomerModel.fromJson(
              map['selectedCustomer'] as Map<String, dynamic>)
          : null,
      lastSaleRequestSaved: map['lastSaleRequestSaved'] as String,
      enterpriseCode: map['enterpriseCode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SaleRequestCartModel.fromJson(String source) =>
      SaleRequestCartModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SaleRequestCartModel(cartProducts: $cartProducts, selectedCustomer: $selectedCustomer, lastSaleRequestSaved: $lastSaleRequestSaved, enterpriseCode: $enterpriseCode)';
  }

  @override
  bool operator ==(covariant SaleRequestCartModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.cartProducts, cartProducts) &&
        other.selectedCustomer == selectedCustomer &&
        other.lastSaleRequestSaved == lastSaleRequestSaved &&
        other.enterpriseCode == enterpriseCode;
  }

  @override
  int get hashCode {
    return cartProducts.hashCode ^
        selectedCustomer.hashCode ^
        lastSaleRequestSaved.hashCode ^
        enterpriseCode.hashCode;
  }
}
