// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models.dart';

class SaleRequestCartModel {
  final List<GetProductJsonModel>? cartProducts;
  final CustomerModel? selectedCustomer;
  final String? lastSaleRequestSaved;
  final String enterpriseCode;
  final String? observations;
  final String? instructions;

  SaleRequestCartModel({
    required this.cartProducts,
    required this.selectedCustomer,
    required this.lastSaleRequestSaved,
    required this.enterpriseCode,
    required this.observations,
    required this.instructions,
  });

  SaleRequestCartModel copyWith(
      {List<GetProductJsonModel>? cartProducts,
      CustomerModel? selectedCustomer,
      String? lastSaleRequestSaved,
      String? enterpriseCode,
      String? observations,
      String? instructions}) {
    return SaleRequestCartModel(
      cartProducts: cartProducts ?? this.cartProducts,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      lastSaleRequestSaved: lastSaleRequestSaved ?? this.lastSaleRequestSaved,
      enterpriseCode: enterpriseCode ?? this.enterpriseCode,
      observations: observations ?? this.observations,
      instructions: instructions ?? this.observations,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cartProducts': cartProducts?.map((x) => x.toJson()).toList(),
      'selectedCustomer': selectedCustomer?.toJson(),
      'lastSaleRequestSaved': lastSaleRequestSaved,
      'enterpriseCode': enterpriseCode,
      'observations': observations,
      'instructions': instructions,
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
      observations: map['observations'] as String,
      instructions: map['instructions'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SaleRequestCartModel.fromJson(String source) =>
      SaleRequestCartModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SaleRequestCartModel(cartProducts: $cartProducts, selectedCustomer: $selectedCustomer, lastSaleRequestSaved: $lastSaleRequestSaved, enterpriseCode: $enterpriseCode, observations: $observations, instructions: $instructions)';
  }

  @override
  bool operator ==(covariant SaleRequestCartModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.cartProducts, cartProducts) &&
        other.selectedCustomer == selectedCustomer &&
        other.lastSaleRequestSaved == lastSaleRequestSaved &&
        other.observations == observations &&
        other.instructions == instructions &&
        other.enterpriseCode == enterpriseCode;
  }

  @override
  int get hashCode {
    return cartProducts.hashCode ^
        selectedCustomer.hashCode ^
        lastSaleRequestSaved.hashCode ^
        observations.hashCode ^
        instructions.hashCode ^
        enterpriseCode.hashCode;
  }
}
